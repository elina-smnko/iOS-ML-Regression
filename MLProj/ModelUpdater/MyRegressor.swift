//
//  MyRegressor.swift
//  MLProj
//
//  Created by Elina Semenko on 13.07.2022.
//

import CoreML



@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class MyRegressorInput : MLFeatureProvider {

    
    var city: String
    var title: String
    var language: String
    var time: String

    var featureNames: Set<String> {
        get {
            return ["city", "title", "language", "time"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "city") {
            return MLFeatureValue(string: city)
        }
        if (featureName == "title") {
            return MLFeatureValue(string: title)
        }
        if (featureName == "language") {
            return MLFeatureValue(string: language)
        }
        if (featureName == "time") {
            return MLFeatureValue(string: time)
        }
        return nil
    }
    
    init(city: String, title: String, language: String, time: String) {
        self.city = city
        self.title = title
        self.language = language
        self.time = time
    }

}


@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class MyRegressorOutput : MLFeatureProvider {

    private let provider : MLFeatureProvider
    lazy var money: Double = {
        [unowned self] in return self.provider.featureValue(for: "money")!.doubleValue
    }()
    var featureNames: Set<String> {
        return self.provider.featureNames
    }
    func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }
    init(money: Double) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["money" : MLFeatureValue(double: money)])
    }
    init(features: MLFeatureProvider) {
        self.provider = features
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class MyRegressor {
    let model: MLModel
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: self)
        return bundle.url(forResource: "MyRegressor", withExtension:"mlmodelc")!
    }
    init(model: MLModel) {
        self.model = model
    }
    @available(*, deprecated, message: "Use init(configuration:) instead and handle errors appropriately.")
    convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<MyRegressor, Error>) -> Void) {
        return self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> MyRegressor {
        return try await self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<MyRegressor, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(MyRegressor(model: model)))
            }
        }
    }
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> MyRegressor {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return MyRegressor(model: model)
    }

    func prediction(input: MyRegressorInput) throws -> MyRegressorOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }

    func prediction(input: MyRegressorInput, options: MLPredictionOptions) throws -> MyRegressorOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return MyRegressorOutput(features: outFeatures)
    }

    func prediction(city: String, title: String, language: String, time: String) throws -> MyRegressorOutput {
        let input_ = MyRegressorInput(city: city, title: title, language: language, time: time)
        return try self.prediction(input: input_)
    }

    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    func predictions(inputs: [MyRegressorInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [MyRegressorOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [MyRegressorOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  MyRegressorOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}

