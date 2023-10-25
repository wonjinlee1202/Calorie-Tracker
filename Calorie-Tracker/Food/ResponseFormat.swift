struct Nutrients: Codable {
    let SUGARadded: Double?
    let CA: Double?
    let CHOCDFnet: Double?
    let CHOCDF: Double?
    let CHOLE: Double?
    let ENERC_KCAL: Double?
    let FAMS: Double?
    let FAPU: Double?
    let FASAT: Double?
    let FATRN: Double?
    let FIBTG: Double?
    let FOLDFE: Double?
    let FOLFD: Double?
    let FOLAC: Double?
    let FE: Double?
    let MG: Double?
    let NIA: Double?
    let P: Double?
    let K: Double?
    let PROCNT: Double?
    let RIBF: Double?
    let NA: Double?
    let Sugaralcohol: Double?
    let SUGAR: Double?
    let THIA: Double?
    let FAT: Double?
    let VITA_RAE: Double?
    let VITB12: Double?
    let VITB6A: Double?
    let VITC: Double?
    let VITD: Double?
    let TOCPHA: Double?
    let VITK1: Double?
    let WATER: Double?
    let ZN: Double?
    
    enum CodingKeys: String, CodingKey {
            case SUGARadded = "SUGAR.added"
            case CA
            case CHOCDFnet
            case CHOCDF
            case CHOLE
            case ENERC_KCAL
            case FAMS
            case FAPU
            case FASAT
            case FATRN
            case FIBTG
            case FOLDFE
            case FOLFD
            case FOLAC
            case FE
            case MG
            case NIA
            case P
            case K
            case PROCNT
            case RIBF
            case NA
            case Sugaralcohol = "Sugar.alcohol"
            case SUGAR
            case THIA
            case FAT
            case VITA_RAE
            case VITB12
            case VITB6A
            case VITC
            case VITD
            case TOCPHA
            case VITK1
            case WATER
            case ZN
        }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        SUGARadded = try container.decodeIfPresent(Double.self, forKey: .SUGARadded)
        CA = try container.decodeIfPresent(Double.self, forKey: .CA)
        CHOCDFnet = try container.decodeIfPresent(Double.self, forKey: .CHOCDFnet)
        CHOCDF = try container.decodeIfPresent(Double.self, forKey: .CHOCDF)
        CHOLE = try container.decodeIfPresent(Double.self, forKey: .CHOLE)
        ENERC_KCAL = try container.decodeIfPresent(Double.self, forKey: .ENERC_KCAL)
        FAMS = try container.decodeIfPresent(Double.self, forKey: .FAMS)
        FAPU = try container.decodeIfPresent(Double.self, forKey: .FAPU)
        FASAT = try container.decodeIfPresent(Double.self, forKey: .FASAT)
        FATRN = try container.decodeIfPresent(Double.self, forKey: .FATRN)
        FIBTG = try container.decodeIfPresent(Double.self, forKey: .FIBTG)
        FOLDFE = try container.decodeIfPresent(Double.self, forKey: .FOLDFE)
        FOLFD = try container.decodeIfPresent(Double.self, forKey: .FOLFD)
        FOLAC = try container.decodeIfPresent(Double.self, forKey: .FOLAC)
        FE = try container.decodeIfPresent(Double.self, forKey: .FE)
        MG = try container.decodeIfPresent(Double.self, forKey: .MG)
        NIA = try container.decodeIfPresent(Double.self, forKey: .NIA)
        P = try container.decodeIfPresent(Double.self, forKey: .P)
        K = try container.decodeIfPresent(Double.self, forKey: .K)
        PROCNT = try container.decodeIfPresent(Double.self, forKey: .PROCNT)
        RIBF = try container.decodeIfPresent(Double.self, forKey: .RIBF)
        NA = try container.decodeIfPresent(Double.self, forKey: .NA)
        Sugaralcohol = try container.decodeIfPresent(Double.self, forKey: .Sugaralcohol)
        SUGAR = try container.decodeIfPresent(Double.self, forKey: .SUGAR)
        THIA = try container.decodeIfPresent(Double.self, forKey: .THIA)
        FAT = try container.decodeIfPresent(Double.self, forKey: .FAT)
        VITA_RAE = try container.decodeIfPresent(Double.self, forKey: .VITA_RAE)
        VITB12 = try container.decodeIfPresent(Double.self, forKey: .VITB12)
        VITB6A = try container.decodeIfPresent(Double.self, forKey: .VITB6A)
        VITC = try container.decodeIfPresent(Double.self, forKey: .VITC)
        VITD = try container.decodeIfPresent(Double.self, forKey: .VITD)
        TOCPHA = try container.decodeIfPresent(Double.self, forKey: .TOCPHA)
        VITK1 = try container.decodeIfPresent(Double.self, forKey: .VITK1)
        WATER = try container.decodeIfPresent(Double.self, forKey: .WATER)
        ZN = try container.decodeIfPresent(Double.self, forKey: .ZN)
    }
}

struct Food: Codable {
    let foodId: String
    let label: String
    let knownAs: String
    let nutrients: Nutrients
    let category: String
    let categoryLabel: String
    let image: String?
}

struct ParsedItem: Codable {
    let food: Food
}

struct ParsedMeasures: Codable {
    let uri: String
    let label: String
    let weight: Double
}

struct ParsedHint: Codable {
    let food: Food
    let measures: [ParsedMeasures]
}

struct _links: Codable {
    let next: _links_next
}

struct _links_next: Codable {
    let title: String
    let href: String
}

struct Response: Codable {
    let text: String
    let parsed: [ParsedItem]
    let hints: [ParsedHint]
    let _links: _links
}
