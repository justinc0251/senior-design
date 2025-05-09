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

    let objectExplanations: [String: String] = [
        // Recycle
        "recycle1": "Plastic bottles (like water or soda bottles) are often made from PET (#1) or HDPE (#2) plastic, which are widely recyclable. Rinse them out and leave the cap on (local rules may vary).",
        "recycle2": "Aluminum cans are highly recyclable and can be recycled indefinitely without losing quality. Rinse them out before recycling.",
        "recycle3": "Cardboard boxes should be flattened before recycling. Remove any plastic tape or inserts if possible.",
        "recycle4": "Glass bottles (clear, brown, green) are recyclable. Rinse them and remove lids (metal lids can often be recycled separately).",
        "recycle6": "Newspapers are made from paper fibers that can be recycled into new paper products.",
        "recycle7": "Office paper (like printer paper or letters) is recyclable. Avoid paper with heavy lamination or food contamination.",
        "recycle8": "Textbooks, especially paperback ones, can be recycled. Hardcovers might need the cover removed depending on local guidelines.",
        "recycle10": "Clean pizza boxes (minimal grease) can be recycled. If heavily soiled with grease and food, the soiled parts should be composted or landfilled.",
        "recycle11": "Many plastic containers (e.g., yogurt cups, butter tubs) are recyclable if they have the recycling symbol (#1, #2, #5 are common). Always check local guidelines as acceptance varies.",
        "recycle12": "Metal cans (like food cans) are typically made from steel or tin and are recyclable. Rinse them out.",
        "recycle13": "Plastic jugs (like milk or detergent jugs) are usually made from HDPE (#2) plastic and are widely recyclable. Rinse and leave caps on (local rules may vary).",
        "recycle14": "Clean aluminum foil (balled up to a size of 2 inches or more) can often be recycled. Check local rules.",
        "recycle15": "Books (paperback) can generally be recycled with other paper products. Hardcover books might require cover removal.",
        "recycle16": "Envelopes, including those with plastic windows, are usually recyclable. Some areas prefer windows removed.",
        "recycle18": "Plastic cups (like disposable drinking cups) may be recyclable if made from accepted plastic types (e.g., #1, #2, #5). Check local rules.",
        "recycle19": "Paper egg cartons are recyclable and compostable. Plastic or foam egg cartons have different disposal methods.",
        "recycle22": "Milk cartons (gable-top, aseptic) are often recyclable. They are typically made of paper coated with a thin layer of plastic. Rinse before recycling.",
        "recycle23": "Plastic containers like take-out containers can be recycled if they are made from accepted plastic types (often #1, #2, or #5) and are clean. Check local rules.",
        "recycle24": "Magazines are made of paper and can be recycled along with newspapers and other paper products.",
        "recycle25": "Metal lids from glass jars and bottles can usually be recycled. It's often best to remove them from the container.",
        "recycle26": "Glass jars (like for food) are recyclable. Rinse them out and remove lids (metal lids can often be recycled separately).",
        "recycle27": "Cardboard toilet paper rolls are recyclable with other paper and cardboard.",

        // Landfill
        "landfill1": "Toothbrushes are typically made from mixed plastics and nylon bristles, which are hard to separate and recycle.",
        "landfill2": "Most disposable coffee cups are lined with plastic, making them difficult to recycle in standard facilities. Some specialized programs exist.",
        "landfill3": "Pet feces can contain harmful bacteria and pathogens, and should not be placed in recycling or compost bins. Bag it and put it in the landfill.",
        "landfill4": "Plastic utensils (forks, spoons, knives) are often made from plastics that are not accepted in curbside recycling (like polystyrene #6).",
        "landfill5": "Plastic straws are generally too small and lightweight to be properly sorted at recycling facilities and can contaminate other recyclables.",
        "landfill7": "Broken glass poses a safety hazard to workers at recycling facilities. Wrap it carefully and place it in the landfill bin.",
        "landfill9": "Diapers (disposable) are made of mixed materials and contain human waste, making them unsuitable for recycling or composting.",
        "landfill10": "Styrofoam or heavily soiled food trays cannot be recycled. Styrofoam is difficult to recycle, and food contamination ruins recyclable materials.",
        "landfill11": "Pens are made of mixed materials (plastic, metal, ink) that are not easily separable for recycling.",
        "landfill12": "Toothpaste tubes are often made of mixed materials (plastic and aluminum layers) and are difficult to clean completely, making them non-recyclable.",
        "landfill13": "Chip bags are typically made from mixed materials (plastic and metallic film) which are not recyclable in most curbside programs.",
        "landfill14": "Disposable coffee cups, especially those with a plastic lining, are generally not recyclable in standard facilities. Check local rules for exceptions.",
        "landfill15": "Bubble wrap is a type of plastic film that can tangle machinery at recycling facilities. Some retail drop-off locations accept clean and dry plastic films.",
        "landfill16": "Packing peanuts (styrofoam) are not recyclable in curbside programs. Some shipping stores may accept them for reuse.",
        "landfill17": "Candy wrappers are usually made of mixed materials or plastics not accepted for recycling.",
        "landfill18": "Heavily soiled napkins cannot be recycled as food and grease contaminate paper fibers. Lightly soiled paper napkins can sometimes be composted.",
        "landfill19": "Rubber bands are not recyclable and can tangle machinery at recycling facilities.",
        "landfill20": "Disposable razors are made of mixed materials (plastic and metal) and are not typically accepted in curbside recycling.",
        "landfill21": "Wet wipes often contain plastic fibers and do not break down like paper, making them unsuitable for recycling or composting. They can also clog pipes if flushed.",

        // Compost
        "compost1": "Many tea bags are made of paper and can be composted. Remove any staples or plastic tags first. Some tea bags contain plastic.",
        "compost2": "Fruit scraps (peels, cores, etc., excluding large pits from some fruits) are excellent organic matter for compost.",
        "compost3": "Vegetable peels and trimmings are great additions to a compost pile, providing valuable nutrients.",
        "compost4": "Coffee grounds are rich in nitrogen and are beneficial for compost. Paper filters can often be composted too.",
        "compost5": "Eggshells add calcium to compost. Crushing them helps them break down faster.",
        "compost6": "Grass clippings can be composted, but add them in thin layers or mix with 'brown' materials to prevent matting and odors.",
        "compost7": "Leaves are a great source of carbon ('brown' material) for compost piles. Shred them for faster decomposition.",
        "compost8": "Plant trimmings from house or garden plants (non-diseased) can be composted. Chop larger pieces.",
        "compost9": "Plain bread (no dairy or oily toppings) can be composted in small amounts. Too much can attract pests.",
        "compost10": "Plain cooked pasta (no sauce or oil) can be composted in moderation.",
        "compost11": "Plain cooked rice can be composted in small amounts.",
        "compost12": "Most nutshells (except for walnut shells, which can inhibit plant growth) can be composted. They break down slowly.",
        "compost13": "Paper napkins (unsoiled with chemicals or grease) can be composted. Avoid those used with harsh cleaning agents.",
        "compost14": "Paper coffee filters can be composted along with coffee grounds.",
        "compost16": "Greasy pizza boxes are often not recyclable due to grease contamination, but the soiled cardboard can be torn up and composted.",
        "compost17": "Avocado pits can be composted, though they take a long time to break down unless chopped or grated.",
        "compost19": "Most nut shells (e.g., peanut, pistachio) can be composted. Avoid black walnut shells as they contain juglone, which can be toxic to some plants.",
        "compost20": "Expired flowers and cut flowers from bouquets are organic matter suitable for composting.",
        "compost21": "Corn husks and cobs can be composted. Cobs will take longer to break down.",
        "compost22": "Untreated wooden chopsticks can be composted. Break them into smaller pieces for faster decomposition.",
        "compost23": "Coconut shells can be composted but will take a very long time to break down unless shredded or crushed into small pieces.",

        // Hazard
        "hazard1": "Batteries contain heavy metals and corrosive chemicals that can leak and contaminate soil and water. They require special disposal.",
        "hazard2": "Motor oil is toxic and should never be poured down drains or onto the ground. Many auto shops and recycling centers accept used motor oil.",
        "hazard3": "Paint cans (especially oil-based) contain chemicals that are harmful to the environment. Latex paint can sometimes be dried out and landfilled, but oil-based always needs special disposal.",
        "hazard4": "Fluorescent light bulbs (including CFLs) contain mercury, a toxic heavy metal. They must be taken to a hazardous waste facility.",
        "hazard5": "Pesticides are toxic chemicals designed to kill pests and can harm humans, animals, and the environment if not disposed of properly.",
        "hazard6": "Herbicides are chemicals used to kill unwanted plants and can be harmful if they enter waterways or soil. They require special disposal.",
        "hazard7": "Propane tanks, even if seemingly empty, can still contain residual gas and pose an explosion risk. They need to be taken to specialized facilities.",
        "hazard8": "Chemical cleaning sprays can contain harsh chemicals harmful to health and the environment. Empty containers might be recyclable if rinsed, but contents need care.",
        "hazard9": "Antifreeze is toxic to animals and humans if ingested. It should be taken to a hazardous waste collection site.",
        "hazard10": "Laptops and other electronics (e-waste) contain heavy metals and other hazardous materials. They should be recycled through e-waste programs.",
        "hazard11": "Mercury thermometers contain elemental mercury, which is highly toxic. If broken, they require careful cleanup and special disposal.",
        "hazard12": "Expired medicines should not be flushed or thrown in the trash, as they can contaminate water. Many pharmacies offer take-back programs.",
        "hazard13": "Nail polish and remover often contain flammable and toxic chemicals and should be treated as hazardous waste.",
        "hazard14": "Aerosol cans that are not completely empty can be explosive or release harmful propellants. Empty cans may be recyclable, but partially full ones are hazardous.",
        "hazard15": "Solvents (like paint thinners or degreasers) are often flammable and toxic, requiring hazardous waste disposal.",
        "hazard16": "Car batteries contain lead and corrosive acid, making them hazardous. They are highly recyclable through battery retailers or scrap metal dealers.",
        "hazard17": "Chemical fertilizers can contaminate water sources if disposed of improperly. Unused portions should be taken to a hazardous waste facility.",
        "hazard18": "Unused fireworks are explosive and pose a fire risk. They should be taken to a hazardous waste facility or handled according to local fire department guidelines.",
        "hazard19": "Smoke detectors may contain a small amount of radioactive material (americium-241) and should be disposed of as hazardous waste or through manufacturer take-back programs.",
        "hazard20": "Insecticides contain toxic chemicals harmful to humans, pets, and the environment. Dispose of them as hazardous waste.",
        "hazard21": "Lead-based paint is highly toxic, especially to children. Items with lead paint or leftover paint need hazardous waste disposal.",
        "hazard22": "Pool chemicals (like chlorine or acids) are corrosive and reactive. They must be handled carefully and taken to a hazardous waste facility.",
        "hazard23": "Syringes and other medical sharps are biohazards and can spread disease. They must be disposed of in designated sharps containers and taken to appropriate collection sites."
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

    func getItemExplanation(for imageName: String) -> String {
        return objectExplanations[imageName] ?? "No explanation available for this item."
    }
}