import UIKit

class WasteData {
    static let shared = WasteData()
    
    // Prevent others from creating instances
    private init() {}
    
    // Content dictionaries
    let objectDescriptions: [String: String] = [
        "recycle1": "Plastic bottles",
        "recycle2": "Aluminum can",
        "recycle3": "Cardboard box",
        "recycle4": "Glass bottle",
        "recycle6": "Newspaper",
        "recycle7": "Office paper",
        "recycle8": "Textbook",
        "recycle10": "Pizza box",
        "recycle11": "Plastic containers",
        "recycle12": "Metal can",
        "recycle13": "Plastic jug",
        "recycle14": "Aluminum foil",
        "recycle15": "Book",
        "recycle16": "Envelope",
        "recycle18": "Plastic cup",
        "recycle19": "Egg carton (paper)",
        "recycle22": "Milk carton",
        "recycle23": "Plastic container",
        "recycle24": "Magazine",
        "recycle25": "Metal lids",
        "recycle26": "Glass jar",
        "recycle27": "Toilet paper roll",
        "landfill1": "Toothbrushes",
        "landfill2": "Coffee cup",
        "landfill3": "Feces",
        "landfill4": "Plastic utensils",
        "landfill5": "Straws",
        "landfill7": "Broken glass",
        "landfill9": "Diaper",
        "landfill10": "Food tray",
        "landfill11": "Pens",
        "landfill12": "Toothpaste",
        "landfill13": "Chip bag",
        "landfill14": "Coffee cup",
        "landfill15": "Bubble wrap",
        "landfill16": "Packing peanuts",
        "landfill17": "Candy wrapper",
        "landfill18": "Soiled napkin",
        "landfill19": "Rubber band",
        "landfill20": "Razor",
        "landfill21": "Wet Wipes",
        "compost1": "Tea bags",
        "compost2": "Fruit scraps",
        "compost3": "Vegetable peels",
        "compost4": "Coffee grounds",
        "compost5": "Eggshells",
        "compost6": "Grass clippings",
        "compost7": "Leaves",
        "compost8": "Plant trimmings",
        "compost9": "Bread",
        "compost10": "Pasta",
        "compost11": "Rice",
        "compost12": "Nutshells",
        "compost13": "Paper napkins",
        "compost14": "Coffee filters",
        "compost16": "Pizza box (greasy)",
        "compost17": "Avocado pits",
        "compost19": "Nut shells",
        "compost20": "Expired flower",
        "compost21": "Corn husk",
        "compost22": "Wooden chopsticks",
        "compost23": "Coconut shell",
        "hazard1": "Batteries",
        "hazard2": "Motor Oil",
        "hazard3": "Paint Can",
        "hazard4": "Fluorescent Light Bulb",
        "hazard5": "Pesticides",
        "hazard6": "Herbicides",
        "hazard7": "Propane Tank",
        "hazard8": "Cleaning Spray",
        "hazard9": "Antifreeze",
        "hazard10": "Laptop",
        "hazard11": "Mercury Thermometer",
        "hazard12": "Expired Medicine",
        "hazard13": "Nail Polish",
        "hazard14": "Aerosol Can",
        "hazard15": "Solvent",
        "hazard16": "Car Battery",
        "hazard17": "Fertilizers",
        "hazard18": "Fireworks",
        "hazard19": "Smoke Detector",
        "hazard20": "Insecticides",
        "hazard21": "Lead-based Paint",
        "hazard22": "Pool Chemicals",
        "hazard23": "Syringes"
    ]

    let categories: [String: [String]] = [
        "recycle": ["recycle1", "recycle2", "recycle3", "recycle4", "recycle6", "recycle7", "recycle8", "recycle10", "recycle11", "recycle12", "recycle13", "recycle14", "recycle15", "recycle16", "recycle18", "recycle19", "recycle22", "recycle23", "recycle24", "recycle25", "recycle26", "recycle27"],
        "landfill": ["landfill1", "landfill2", "landfill3", "landfill4", "landfill5", "landfill7", "landfill9", "landfill10", "landfill11", "landfill12", "landfill13", "landfill14", "landfill15", "landfill16", "landfill17", "landfill18", "landfill19", "landfill20", "landfill21"],
        "compost": ["compost1", "compost2", "compost3", "compost4", "compost5", "compost6", "compost7", "compost8", "compost9", "compost10", "compost11", "compost12", "compost13", "compost14", "compost16", "compost17", "compost19", "compost20", "compost21", "compost22", "compost23"],
        "hazard": ["hazard1", "hazard2", "hazard3", "hazard4", "hazard5", "hazard6", "hazard7", "hazard8", "hazard9", "hazard10", "hazard11", "hazard12", "hazard13", "hazard14", "hazard15", "hazard16", "hazard17", "hazard18", "hazard19", "hazard20", "hazard21", "hazard22", "hazard23"]
    ]
    
    // Helper methods
    func getItemTitle(for imageName: String) -> String {
        return objectDescriptions[imageName] ?? "Unknown Item"
    }
    
    func getCategory(for imageName: String) -> String? {
        if imageName.hasPrefix("recycle") {
            return "recycle"
        } else if imageName.hasPrefix("compost") {
            return "compost"
        } else if imageName.hasPrefix("landfill") {
            return "landfill"
        } else if imageName.hasPrefix("hazard") {
            return "hazard"
        }
        return nil
    }
    
    func getDisplayNameForCategory(_ category: String) -> String {
        switch category {
        case "recycle": return "Recycle"
        case "compost": return "Compost"
        case "landfill": return "Landfill"
        case "hazard": return "Hazardous"
        default: return "Unknown"
        }
    }
}