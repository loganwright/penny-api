import Mint
import Vapor
import GitHub
import Fluent
import FluentPostgreSQL

struct CoinResponse: Content {
    let coin: Coin
    let total: Int
}

import Foundation

public let originalCoinTable = """
| U0N81DSSH            |   467 |
| U0N6AKFK3            |   613 |
| U1PF52H9C            |    16 |
| U0ZLYJ3BN            |     5 |
| U186RQ6SK            |     1 |
| U1J7QTC3E            |     1 |
| U1RGR49UP            |   193 |
| U0Y685YKB            |    35 |
| U0N7YMP8C            |    10 |
| U191W6YSZ            |     2 |
| U0X8JPPFX            |   299 |
| U1R4ELLEN            |    17 |
| U1WLE0G7R            |     2 |
| U195DUGGH            |     5 |
| U1B1ZCMAS            |     2 |
| U166TV97G            |     1 |
| U18C27HRD            |    10 |
| U1QLL02HY            |     2 |
| U1YNXLKNF            |     2 |
| U0N9XRRU5            |    21 |
| U1E9VGEQJ            |     1 |
| U1Y4C44AK            |     4 |
| U1YUG29TL            |     4 |
| U1CJC1V3Q            |     9 |
| U17KS7RFS            |     1 |
| U214JSLTW            |     1 |
| U2181431V            |     2 |
| U20QWT6P4            |     3 |
| U200KRD2Q            |     4 |
| U1NDEAHPU            |    12 |
| U2232N9M0            |     5 |
| U1PQZ20CS            |     5 |
| U1B843A65            |     2 |
| U1ZKHHY5R            |     5 |
| U1LNSMK52            |     2 |
| U23M81GBY            |     3 |
| U23AQFUDB            |     1 |
| U25AKP2HH            |     2 |
| U1X3UQ6DS            |     5 |
| U25V1BVLJ            |    15 |
| U1E13GDJ9            |     1 |
| U268HJR5W            |     3 |
| U268595GW            |    11 |
| U1HFB3HU0            |     1 |
| U2723M4SZ            |    42 |
| U11950BNK            |    11 |
| U26NM6V42            |     3 |
| U269KC3MX            |     1 |
| U27SKH4FQ            |     1 |
| U19CZM1HU            |     5 |
| U139SPSRW            |     1 |
| U27965LSW            |     1 |
| U1B0E044B            |     1 |
| U1W1EV1B2            |   225 |
| U1BLAPSNP            |     8 |
| U22EG2KAT            |     3 |
| U1X4ZCSLE            |     1 |
| U2CBXJTFX            |     1 |
| U23FKMPEY            |     1 |
| U2CDY1B4Y            |   134 |
| U1E9M538S            |    25 |
| U2DBFLQV6            |     3 |
| U18RFD3K4            |    29 |
| U2DER69TJ            |     9 |
| U2CNHKFFW            |     3 |
| U2CH7GDDK            |     4 |
| U2F06B0KS            |     1 |
| U24L02WSW            |    27 |
| U1XHAHQBU            |     4 |
| U2FEDBSMA            |     1 |
| U2EE18MPC            |     1 |
| U2FN8T1SN            |     4 |
| U2EKLEG1H            |     3 |
| U0ZC6TLJF            |     9 |
| U0NGLT0KG            |     3 |
| U2EJANX4Z            |     1 |
| U0X9NJ3M3            |     2 |
| U1SCQB81E            |    68 |
| U1K6L1J1Z            |     6 |
| U2H8HUZK8            |     3 |
| U14C4J2AD            |     1 |
| U2LK2PYNR            |     1 |
| U2KSR2WJU            |     1 |
| U1B67D0Q3            |   168 |
| U2C3B1RC7            |    30 |
| U2KHX3AN5            |     1 |
| U2BTH95TR            |     1 |
| U2F1B0TPB            |     6 |
| U2HQJD5HC            |   136 |
| U2GKV2RL7            |     2 |
| U2FRSHSFN            |     1 |
| U0XBK5370            |     2 |
| U19MEAWF4            |     1 |
| U2GEG588G            |     2 |
| U1G5XRC9M            |     3 |
| U1U2WFG9W            |     6 |
| U1NTSTGC9            |     1 |
| U2M5Z6XQ9            |     1 |
| U2DTDB0JD            |   140 |
| U1W8U0XSQ            |     1 |
| U2PL3BRPU            |     7 |
| U2RDGFC1K            |     2 |
| U2M28KLA1            |     2 |
| U2NREK99C            |     2 |
| U2HPU7PPW            |     5 |
| U2EB7HNQ7            |    10 |
| U2RPFA0MB            |    22 |
| U2QEB6894            |     1 |
| U1P9MTZ1T            |     3 |
| U1U3X21EK            |     2 |
| U2R85LUBZ            |     1 |
| U2C9GPRRT            |     3 |
| U2FMEC49J            |    25 |
| U2TEKMQA1            |     1 |
| U1VQEPF0B            |     7 |
| U2NUJ5HEU            |     1 |
| U2G6C1YU9            |     1 |
| U2FPUDJ30            |    15 |
| U2SU4PRPA            |     4 |
| U2RCW7R6U            |     2 |
| U2T0JMCKH            |     2 |
| U25MVEGA2            |     1 |
| U25J3ED8S            |     3 |
| U2FEWSE8L            |    22 |
| U1QTNQ9E2            |     1 |
| U11QBHPCY            |     1 |
| U1957N9NU            |     1 |
| U2T0ZGB45            |     1 |
| U2KLEN3A9            |    43 |
| U2PNMHHBJ            |     1 |
| U2X950SAF            |     1 |
| U2V8PBULW            |     1 |
| U2MHYH049            |    12 |
| U2X0Q9EHY            |     1 |
| U2TGL2H60            |  1055 |
| U2W6TSCA0            |     2 |
| U1458KU6L            |   199 |
| U2Z3B0344            |     2 |
| U2YTN9FGS            |     1 |
| U2CQH6M0B            |     2 |
| U2Z3Q003U            |     1 |
| U2ZU6BDB7            |     1 |
| U2VFH5030            |     1 |
| U2ZJS0082            |     2 |
| U2SPA03K3            |     1 |
| U2UPVAUDC            |     1 |
| U2NJHFE9F            |     6 |
| U19C91X1C            |     1 |
| U322PRKJ9            |     1 |
| U2V285JJ1            |     6 |
| U2S37KQKD            |   195 |
| U2JK5GDMF            |     1 |
| U310D2N68            |     1 |
| U1U2J501L            |     1 |
| U34RS9AM9            |     1 |
| U2URB4TV4            |     2 |
| U2JAKFBD5            |     2 |
| U2XDB0SFM            |     2 |
| U33T1S0RY            |     2 |
| U31J14WHG            |     1 |
| U2FFC42BW            |     3 |
| U35A6EHCN            |     4 |
| U2C8VQWJ1            |     1 |
| U2J997H96            |     1 |
| U26JY7S6A            |    95 |
| U11EGARC3            |    23 |
| U380DSY9K            |    10 |
| U382KA9N1            |    81 |
| U32J0P5HB            |    15 |
| U354K6FDG            |     2 |
| U38476FJP            |  1199 |
| U35PLE6GN            |     1 |
| U21CX4317            |     1 |
| USLACKBOT            |    20 |
| U3BP8BD0X            |    11 |
| U2LLR5UJ1            |     1 |
| U34KXMTRN            |     6 |
| U1SCBQWR3            |     4 |
| U2S4GSKJS            |     3 |
| U3EGT8EJ2            |     1 |
| U3ETYE99Q            |     1 |
| U3HKEE13R            |     2 |
| U3GENFD61            |     4 |
| U3C16ADA8            |     1 |
| U3CF5SXSQ            |     1 |
| U3G62GK50            |     1 |
| U38NB9LQP            |     2 |
| U2FHJQKHB            |    11 |
| U3G7WE8P6            |     5 |
| U2WUELN5B            |    27 |
| U3JTG9VMJ            |     1 |
| U3KDFSLDD            |     9 |
| U2T258ALD            |     4 |
| U119Z1T4M            |     5 |
| U3G6T954N            |     3 |
| U1U2WFG9W            |     2 |
| U2EH3RAS1            |     4 |
| U3L8W8R7W            |     2 |
| U37HUNR39            |     3 |
| U0Q4NBHD2            |     2 |
| U3JN7CXSB            |     3 |
| U2R2JGTQB            |    16 |
| U3NQE5T3P            |     2 |
| U39KN8LLT            |     7 |
| U2F89BF9P            |     1 |
| U3AUBLA1L            |    77 |
| U3PCA0VEZ            |    31 |
| U1ADS4ML7            |    10 |
| U2CSM081G            |    20 |
| U3S5CFSHL            |     4 |
| U3PD0DKB8            |     2 |
| U375UMX2N            |     1 |
| U3QE1RA4A            |     1 |
| U186ELK1R            |     1 |
| U3NE4KZPW            |     1 |
| U3JFRQF0U            |     2 |
| U2U3X552N            |     2 |
| U2UEBRX7G            |     1 |
| U3RP61J3C            |     3 |
| U3EUPSYM6            |     1 |
| U318G99EG            |     9 |
| U32LT4HNF            |     5 |
| U3TS9PBV3            |     2 |
| U281Z1H5K            |     1 |
| U1P58UBB7            |     3 |
| U3ULADN58            |     3 |
| U2EEPAQCT            |     3 |
| U2D0V1518            |     1 |
| U3UEQ85NH            |     1 |
| U3VLE2D61            |     1 |
| U2TNK41LL            |     1 |
| U20K7GDGF            |     1 |
| U3X8HG74N            |     1 |
| U1UKV6TK9            |     1 |
| U3WK185SP            |    19 |
| U3X8XPUAJ            |     2 |
| U3U5Y0MS5            |     1 |
| U3HHCL46S            |     2 |
| U3K3C5K61            |     1 |
| U2CU1VAF9            |     2 |
| U3W5AR0C8            |    19 |
| U3C4LEYDA            |     4 |
| U1V3R011U            |     4 |
| U3ZPU21CN            |    12 |
| U43DWHU3A            |     1 |
| U42FT3WHM            |     1 |
| U2WRFDRQS            |     6 |
| U44KGHJ56            |     1 |
| U3PMM0PRD            |     1 |
| U3LT6H879            |     1 |
| U44BZ895G            |     1 |
| U2DDM7CQP            |     1 |
| U45FJ37A7            |     1 |
| U0SDY1Q0M            |     1 |
| U3YRVN8P6            |     1 |
| U2DRG1V50            |     1 |
| U3K0XF563            |     2 |
| U3WT9CM8Q            |     6 |
| U48LUQWP7            |     1 |
| U19D1QKQU            |     1 |
| U3442R347            |     1 |
| U2TJ4D4A3            |     1 |
| U48AL2B43            |     4 |
| U4CHJAH9N            |     1 |
| U41ETFVL1            |     1 |
| U4FJ7L2H4            |     1 |
| U2EKHSNPR            |     2 |
| U4GSN9SDQ            |     8 |
| U335A4D28            |     6 |
| U4HR2HDBQ            |     6 |
| U38G54K6D            |     1 |
| U44J5S8TB            |     2 |
| U4K3Q8XB9            |     2 |
| U3F0Q4HRA            |     1 |
| U48CC6JCU            |     1 |
| U4K1QLXRB            |     1 |
| U4H5AQ6DR            |   152 |
| U2CNYTSBW            |     2 |
| U3FHHNT44            |     1 |
| U45NTM797            |     1 |
| U34HAKBJA            |    12 |
| U4PNH6UV8            |     8 |
| U4R2J6TPH            |     4 |
| U4HP50VB9            |     1 |
| U3TGE7K4L            |     3 |
| U2M3K0FJ6            |     4 |
| U4HRDP8AY            |     3 |
| U4U1SGRB4            |     1 |
| U4R61UUSW            |     5 |
| U4T9GGZK2            |     1 |
| U4CQALPUP            |     7 |
| U4U3BSYBC            |     8 |
| U4H0D0YSU            |     4 |
| U42H1B685            |     4 |
| U4UFTNEAF            |     1 |
| U3KKJ4PL3            |     1 |
| U4YMH14DT            |     1 |
| U3E2AU170            |     2 |
| U4ZABR7EJ            |     1 |
| U0NKZT0DN            |     4 |
| U4XRLNB8C            |     3 |
| U2UNDRH9S            |     2 |
| U5008H1QA            |     3 |
| U4FL69U3S            |     2 |
| U4ZUYPY5B            |     5 |
| U4VK02QEN            |     1 |
| U4QE8LJAV            |     3 |
| U4JFFDR3P            |     4 |
| U522DC1S4            |     1 |
| U52FT1YKB            |     1 |
| U4V824GBV            |     7 |
| U3JBM2CAJ            |     2 |
| U52HY84TA            |     5 |
| U2VKEP7ME            |     3 |
| U4V32QW9K            |     1 |
| U53MSPG0L            |     3 |
| U53E105M3            |     1 |
| U2W0F5H37            |     1 |
| U541AR5DZ            |    20 |
| U4S8JHDJP            |     2 |
| U3ZAWUYL9            |     1 |
| U4Q9XSDB9            |     3 |
| U59MBDUBU            |     8 |
| U0SPFNRPC            |     5 |
| U57D44GC8            |     1 |
| U1RGR49UP            |     4 |
| U50128ZN2            |     4 |
| U547RLK3R            |     9 |
| U5EMXB877            |     1 |
| U59TJPN4W            |     1 |
| U4AJJ743W            |     1 |
| U5EUY7VH7            |     3 |
| U3TVCF4P6            |     1 |
| U586ZM4JD            |     1 |
| U5ET4QUCT            |     1 |
| U4P694H4N            |     4 |
| U39N12JH5            |     2 |
| U5AFYM24F            |     2 |
| U5C185R2T            |     1 |
| U5J4X31ML            |     1 |
| U51UGLZLP            |     3 |
| U29QYSE3T            |     1 |
| U3W3BAS87            |     2 |
| U5JK8V4Q2            |     1 |
| U1VLW4SHL            |     1 |
| U188FQXJM            |     1 |
| U58JJA230            |     1 |
| U4H9L14Q3            |     3 |
| U2Z2BTR36            |     1 |
| U43AXB0TG            |     3 |
| U5LUZQG9K            |     7 |
| U49DL8P2Q            |     1 |
| U3Q2WSHEW            |     4 |
| U55D3A6MA            |     1 |
| U5N34JJKZ            |     1 |
| U48ACHWMD            |    11 |
| U5PADUWN7            |     1 |
| U4V545L90            |     6 |
| U5KMLTX0R            |     1 |
| U5XLY8C4B            |     1 |
| U3QKG4V0X            |     1 |
| U4WP6EKFZ            |     1 |
| U5K85748M            |     1 |
| U2KKGQU1G            |     1 |
| U4ZP316M8            |     1 |
| U63APBNRG            |     8 |
| U2R5LKCFR            |     2 |
| U61G4DL8G            |    18 |
| U5ZA62ZMH            |    60 |
| U3N0UR02U            |     1 |
| U673A5JG2            |     1 |
| U486EGWG7            |     1 |
| U65ESLYMA            |     6 |
| U6687G62D            |     2 |
| U6DMAP0EB            |     3 |
| U60QFDZQF            |     4 |
| U48RG59D3            |     2 |
| U6KJVQMSS            |     1 |
| U67P3TERF            |    21 |
| U473M1MK9            |     2 |
| U6G4TDAJY            |     1 |
| U4CK6DL90            |     1 |
| U54R7QV38            |     4 |
| U434HJE0P            |     1 |
| U2ZN8JW3A            |     2 |
| U60K0MAGJ            |     1 |
| U535S6K99            |     1 |
| U3K6RQ3E0            |     3 |
| U78DN73P1            |     2 |
| U787N1PU4            |     1 |
| U6QEQ3XDY            |     4 |
| U73EW4664            |     2 |
| U7ETKMVLG            |     1 |
| U48BMS5DJ            |     1 |
| U7PQ0QA4A            |     1 |
| U7RJJ49C5            |     1 |
| U7PA5GGM6            |     2 |
| U0V43F10D            |     1 |
| U28FRHNVD            |     1 |
| U79R7M5S4            |     1 |
| U7RAVCR89            |     1 |
| U5FCTEVAM            |     1 |
| U59JZ5S13            |     3 |
| U7MCPMDE3            |     1 |
| U7P3X5400            |    39 |
| U84UY6PB2            |     1 |
| U5K2XGK8T            |     7 |
| U6S6GGGLS            |     2 |
| U55S4LZJM            |     1 |
| U2GKFG28M            |     6 |
| U7ZADNXE0            |     1 |
| U8CKDQLSV            |     1 |
| U4F2LEKMW            |    89 |
| U8HD5F9JN            |     1 |
| U677Q7SLA            |     7 |
| U54CUCMQA            |    26 |
| U8U21955L            |     4 |
| U8UDTSGKY            |     1 |
| U8WNZRM5H            |     1 |
| U8ZUXU8SH            |     1 |
| U8QEGRV40            |     1 |
| U90HQF0QG            |     8 |
| U5N79L44T            |    11 |
| U5RP8TG4F            |     1 |
| U7RBY1Y6P            |     2 |
| U8Q6BCG79            |    30 |
| U46JLN3K5            |     1 |
| U2S9VFP2N            |     1 |
| U4EQQKS9X            |     7 |
| U8A1N6CDP            |     3 |
| U18SRJ3FB            |     1 |
| U8ZPTFD9B            |     1 |
| U6H0ZA5E0            |     4 |
| U94BL54NL            |     2 |
| U8YKV08TG            |     1 |
| U6FDN7XH9            |     3 |
| U3YQ3R1PY            |     1 |
| U23483212            |     2 |
| U98ETFR1A            |     8 |
| U7SG7PYEA            |    39 |
| U9CEUCUBT            |     2 |
| U2HBKURQD            |     1 |
| U9AEC5Q7L            |     6 |
| U9BFXCL3U            |     3 |
| U9GAW0ZEV            |    30 |
| U9G4TL14Y            |    12 |
| U96L4DRPG            |     6 |
| U9A8GRCCR            |     1 |
| U99VAHQ57            |     1 |
| U8XKMS4V7            |     1 |
| U9LQFQZTQ            |     7 |
| U37RUNBQQ            |     5 |
| U9N5TA371            |     1 |
| U9LVDGTGS            |     2 |
| U8FLP3AG3            |     4 |
| U139FSL3S            |     9 |
| U9JPK26P5            |    17 |
| U9RC2M89M            |     2 |
| U9JR63USC            |    20 |
| U3K0T2D19            |     5 |
| U9J80GSM9            |    14 |
| U5YT6KUGH            |     3 |
| U93FZ26H1            |     1 |
| U5QQH2TLK            |     1 |
| U8GM7Q412            |     1 |
| U2CKV2SMA            |     2 |
| U9G7VAVLK            |     2 |
| U69CNCB8C            |     1 |
| U3P2PNYAC            |     1 |
| U6BUAJWBT            |     1 |
| U8JJL2YL9            |     1 |
| U6S0W3UE5            |     2 |
| U96GRFRBM            |     1 |
| U1W3EHSBV            |     5 |
| U9L8TJWD6            |     2 |
| U96LMEDC1            |     1 |
| U8Y9LPQN4            |     1 |
| U1B5B788L            |     1 |
| U9JQ26GDR            |     1 |
| U6R0AD20K            |     1 |
| UA6811DT9            |     1 |
| U9DU9JE31            |     1 |
| U1WQVE81G            |     1 |
| UA67ZNV60            |     2 |
| UA37XP031            |     1 |
| U9KT7LD97            |     7 |
| U9SNK9X1S            |     1 |
| UA7L1AHU7            |     1 |
| UA5RH8093            |     1 |
| U3H74JERY            |     1 |
| U6SU0LUKT            |     6 |
| U4CQ7EPHT            |     2 |
| UA0GXG9S5            |     1 |
| UA8448WE9            |     1 |
| U3Y3YTZK2            |     1 |
| UAEQA3ZDG            |     1 |
| UAJEA8TD1            |     2 |
| U2PLGU4DD            |     1 |
| U9XUP6532            |     1 |
| U975JH0P9            |     2 |
"""

/* private but tests */ internal extension Character {
    var isASCIIWhitespace: Bool {
        return self == " " || self == "\t" || self == "\r" || self == "\n" || self == "\r\n"
    }
}

/* private but tests */ internal extension String {
    func trimASCIIWhitespace() -> Substring {
        return self.dropFirst(0).trimWhitespace()
    }
}

private extension Substring {
    func trimWhitespace() -> Substring {
        var me = self
        while me.first?.isASCIIWhitespace == .some(true) {
            me = me.dropFirst()
        }
        while me.last?.isASCIIWhitespace == .some(true) {
            me = me.dropLast()
        }
        return me
    }
}

public func pennyapi(_ open: Router) throws {
    // Run through basic auth verification
    let secure = open.grouped(PennyAuthMiddleware())
    let devonly = open.grouped(DevelopmentOnlyMiddleware()).grouped("dev")

    open.get("migrate-coins") { (req) -> Future<[Coin]> in
        var table = [String: Int]()

        originalCoinTable.split(separator: "\n").map { $0.split(separator: "|").map { $0.trimWhitespace() } }.forEach { pair in
            let id = String(pair[0])
            let value = Int(String(pair[1]))!

            var existing = table[id] ?? 0
            existing += value
            table[id] = existing
        }

        let coins = table.map { to, val -> Coin in
            return Coin(source: "slack", to: to, from: "transfer", reason: "penny-slack-transfer")
        }

        return coins.map { $0.save(on: req) } .flatten(on: req)
    }
    // MARK: Development Endpoints

    open.get("fix-coins") { req -> Future<[Coin]> in
        return Coin.query(on: req).all().flatMap(to: [Coin].self) { coins in
            let discord = coins.filter { $0.source == "discord" } .filter { $0.to.hasPrefix("!") || $0.from.hasPrefix("!") }

            let fixed = discord.map { coin in
                if coin.to.hasPrefix("!") {
                    coin.to = String(coin.to.dropFirst())
                }
                if coin.from.hasPrefix("!") {
                    coin.from = String(coin.from.dropFirst())
                }
                return coin.save(on: req)
            } as [Future<Coin>]

            return fixed.flatten(on: req)
        }
    }

    open.get("fix-accounts") { req -> Future<[Account]> in
        let vault = Vault(req)

        return Account.query(on: req).all().flatMap(to: [Account].self) { accounts in
            let filtered = accounts.filter { $0.discord?.hasPrefix("!") == true }
            return try vault.accounts.delete(filtered).map(to: [Account].self) { _ in return filtered }
        }

//        let discordAccounts = try Account.query(on: req).filter(\.discord != nil).all()
//        return discordAccounts.flatMap(to: [Account].self) { discordAccounts in
//            let cleaned = discordAccounts.map { account in
//                if let val = account.discord, val.hasPrefix("!") {
//                    account.discord = String(val.dropFirst())
//                }
//                return account
//            } as [Account]
//
//            var matchedAccounts: [String: [Account]] = [:]
//            for account in cleaned {
//                guard let discord = account.discord else { continue }
//                var accounts = matchedAccounts[discord]
//                accounts?.append(account)
//                matchedAccounts[discord] = accounts
//            }
//
//            let new = matchedAccounts.values.map { group in
//                let new = Account(slack: nil, github: nil, discord: nil)
//                group.forEach { existing in
//                    if let slack = existing.slack {
//                        new.slack = slack
//                    }
//                    if let discord = existing.discord {
//                        new.discord = discord
//                    }
//                    if let github = existing.github {
//                        new.github = github
//                    }
//                }
//                return new
//            } as [Account]
//
//            return try vault.accounts.delete(matchedAccounts.values.flatMap { $0 }).flatMap(to: [Account].self) { _ in
//                return new.map { $0.save(on: req) } .flatten(on: req)
//            }
//        }

//        return Coin.query(on: req).all().flatMap(to: [Coin].self) { coins in
//            let discord = coins.filter { $0.source == "discord" } .filter { $0.to.hasPrefix("!") || $0.from.hasPrefix("!") }
//
//            let fixed = discord.map { coin in
//                if coin.to.hasPrefix("!") {
//                    coin.to = String(coin.to.dropFirst())
//                }
//                if coin.from.hasPrefix("!") {
//                    coin.from = String(coin.from.dropFirst())
//                }
//                return coin.save(on: req)
//                } as [Future<Coin>]
//
//            return fixed.flatten(on: req)
//        }
    }

    open.get("coins") { Coin.query(on: $0).all() }
    open.get("accounts") { Account.query(on: $0).all() }
    open.get("links") { AccountLinkRequest.query(on: $0).all() }
    open.get("coins", String.parameter, String.parameter) { req -> Future<[Coin]> in
        let source = try req.parameters.next(String.self)
        let id = try req.parameters.next(String.self)

        let mint = Vault(req)
        return try mint.coins.all(source: source, sourceId: id)
    }

    // MARK: Secure Status

    secure.get("secure") { _ in "authorized" }

    // MARK: Coin Totals

    struct TotalResponse: Content {
        let total: Int
    }

    open.get("coins", String.parameter, String.parameter, "total") { req -> Future<TotalResponse> in
        let source = try req.parameters.next(String.self)
        let id = try req.parameters.next(String.self)

        let vault = Vault(req)
        return try vault.coins.total(source: source, sourceId: id).map(TotalResponse.init)
    }

    open.get("coins", "github-username", String.parameter, "total") { req -> Future<TotalResponse> in
        let username = try req.parameters.next(String.self)
        let github = GitHub.Network(req, token: PENNY_GITHUB_TOKEN)
        let user = try github.user(login: username)

        let vault = Vault(req)
        let total = user.flatMap(to: Int.self) { user in
            return try vault.coins.total(source: user.externalSource, sourceId: user.externalId)
        }
        return total.map(TotalResponse.init)
    }

    // MARK: Post Coin

    secure.post("coins") { request -> Future<[CoinResponse]> in
        struct Package: Content {
            let from: String
            let to: String
            let source: String
            let reason: String

            let value: Int?
        }

        let vault = Vault(request)

        let pkgs = try request.content.decode([Package].self)
        let coins = pkgs.flatMap(to: [Coin].self) { pkgs in
            return pkgs.map { pkg in
                vault.coins.give(to: pkg.to, from: pkg.from, source: pkg.source, reason: pkg.reason, value: pkg.value)
            }.flatten(on: request)
        }

        let pairs = coins.map(to: [(coin: Coin, total: Future<Int>)].self) { coins in
            return try coins.map { coin in
                return (coin, try vault.coins.total(source: coin.source, sourceId: coin.to))
            }
        }

        return pairs.flatMap(to: [CoinResponse].self) { pairs in
            return pairs.map { pair in
                return pair.total.map(to: CoinResponse.self) { total in
                    return CoinResponse(coin: pair.coin, total: total)
                }
            } .flatten(on: request)
        }
    }

    // MARK: Accounts

    secure.get("accounts", String.parameter, String.parameter) { req -> Future<Account> in
        let source = try req.parameters.next(String.self)
        let id = try req.parameters.next(String.self)

        let vault = Vault(req)
        return try vault.accounts.get(source: source, sourceId: id)
    }

    // MARK: Links

    // Submit GitHub Link Request
    secure.post("links", "github") { req -> Future<GitHubLinkResponse> in
        let pkg = try req.content.decode(GitHubLinkInput.self)
        return pkg.flatMap(to: GitHubLinkResponse.self) { pkg in
            return try GitHubLinkBuilder.linkGitHub(on: req, with: pkg)
        }
    }

    // Submit Link Request
    secure.post("links") { req -> Future<AccountLinkRequest> in
        struct Package: Content {
            let initiationSource: String
            let initiationId: String

            let requestedSource: String
            let requestedId: String

            let reference: String
        }

        let pkg = try req.content.decode(Package.self)
        let vault = Vault(req)
        return pkg.flatMap(to: AccountLinkRequest.self) { pkg in
            return try vault.linkRequests.create(
                initiationSource: pkg.initiationSource,
                initiationId: pkg.initiationId,
                requestedSource: pkg.requestedSource,
                requestedId: pkg.requestedId,
                reference: pkg.reference
            )
        }
    }

    // Retrieve Existing Link Request
    secure.get("links") { req -> Future<AccountLinkRequest> in
        struct Package: Content {
            let requestedSource: String
            let requestedId: String

            let reference: String
        }

        let pkg = try req.content.decode(Package.self)


        let vault = Vault(req)
        let found = pkg.flatMap(to: AccountLinkRequest?.self) { pkg in
            return try vault.linkRequests.find(
                requestedSource: pkg.requestedSource,
                requestedId: pkg.requestedId,
                reference: pkg.reference
            )
        }

        return found.map(to: AccountLinkRequest.self) { found in
            guard let found = found else { throw "no record found" }
            return found
        }
    }

    // Approve Existing Link Request
    secure.post("links", "approve") { req -> Future<Account> in
        let link = try req.content.decode(AccountLinkRequest.self)

        let vault = Vault(req)
        return link.flatMap(to: Account.self, vault.linkRequests.approve)
    }
}
