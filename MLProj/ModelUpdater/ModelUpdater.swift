import CoreML
#if os(iOS)
import CreateML
#endif


struct UpdateInput {
    let city: String
    let title: String
    let language: String
    let time: String
    let money: Double
}

struct ModelUpdater {
    // MARK: - Private Type Properties
    private static var updatedRegressor: MyRegressor? = nil
    private static var defaultRegressor: MyRegressor? {
        guard let regressor = createModel(first: true) else {
            print("model error")
            return nil }
        return MyRegressor(model: regressor.model)
    }

    // The regressor model currently in use.
    private static var liveModel: MyRegressor? {
        updatedRegressor ?? defaultRegressor
    }
    
    /// The Model Updater type doesn't use instances of itself.
    private init() { }
    
    // MARK: - Public Type Methods
    static func predictMoneyFor(_ value: MyRegressorInput) -> Double? {
        return try? liveModel?.prediction(input: value).money
    }

    static func updateWith(input: UpdateInput) {
        do {
            guard let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else { return }
            let url = dir.appendingPathComponent("data.csv")
            try "\(input.city),\(input.title),\(input.language),\(input.time),\(input.money)".appendLineToURL(fileURL: url as URL)
        }
        catch {
            print("Could not write to file")
        }
        
        guard let regressor = createModel(first: false) else { return }
        updatedRegressor = MyRegressor(model: regressor.model)
    }
    
    private static func createModel(first: Bool) -> MLLinearRegressor? {
        
        var csvFile: URL?
        
        if first {
            csvFile = Bundle.main.url(forResource: "data", withExtension: "csv")
            guard let file = csvFile, let string = try? String(contentsOf: file, encoding: .utf8), let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("data.csv") else { return nil }
            if let data = string.data(using: .utf8) {
                do {
                    try data.write(to: url)
                } catch {
                    print("unsuccessful write")
                }
            }
        } else {
            csvFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("data.csv")
        }
        
        guard let csvFile = csvFile, let dataTable = try? MLDataTable(contentsOf: csvFile) else { return nil }
        
        let regressorColumns = ["city", "title", "language", "time", "money"]
        let regressorTable = dataTable[regressorColumns]
        
        let (_, regressorTrainingTable) = regressorTable.randomSplit(by: 0.20, seed: 5)
        
        guard let regressor = try? MLLinearRegressor(trainingData: regressorTrainingTable,
                                                     targetColumn: "money") else { return nil}
        
        return regressor
    }
    
    /// Deletes the updated model and reverts back to originalr.
    static func reset() {
        // Clear the updated model.
        updatedRegressor = nil
    }
}
