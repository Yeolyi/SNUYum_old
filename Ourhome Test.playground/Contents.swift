import SwiftSoup
import SwiftUI

func getCost(menuName: String) -> Int {
    switch menuName {
    case "menu_a":
        return 2000
    case "menu_b":
        return 2500
    case "menu_c":
        return 3000
    case "menu_d":
        return 3500
    case "menu_e":
        return 4000
    case "menu_f":
        return 5000
    default:
        return 0
    }
}

let currentDate = getDate(from: "2020/09/12 00:00")
let uRLContents = try String(contentsOf: makeURL(from: currentDate))
let parsed = try! parse(uRLContents)

let rawCafeList = try! parsed.select("div#container").select("tr").array() //가로줄 구분
var count = 0
for element in rawCafeList {
    count += 1
    if count > 8 {
        break
    }
    for ele in try! element.select("td").array() { //네모 하나하나
        if try! ele.select("li").text() != "" {
            print(try! ele.select("li").text())
            print(getCost(menuName: try! ele.select("li").attr("class")))
        }
        else {
            print("없음")
        }

        print()
    }
}

func makeURL(from date: Date) -> URL {
    let baseNum = 1597503600
    let baseDate = getDate(from: "2020/08/16 00:00")
    let components = Calendar.current.dateComponents([.weekOfYear], from: baseDate, to: date)
    //print("\(baseDate)부터 \(date)까지 \(components.weekOfYear!)주 지났습니다")
    return URL(string: "https://dorm.snu.ac.kr/dk_board/facility/food.php?start_date2=\(baseNum + components.weekOfYear! * 604800)")!
}

///yyyy/MM/dd HH:mm 형식을 Date로 변환
func getDate(from string: String) -> Date{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    let date = formatter.date(from: string)!
    guard let trimmedDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: date)) else {
        assertionFailure("")
        return Date()
    }
    return trimmedDate
}

func parse(_ uRL: URL) -> Document {
    do {
        let uRLContents = try String(contentsOf: uRL)
        let parsedURLContents: Document = try SwiftSoup.parse(uRLContents)
        return parsedURLContents
    }
    catch {
        assertionFailure("HTMLManager/parse(): URL 파싱에 실패하였습니다.")
    }
    return .init("https://dorm.snu.ac.kr/dk_board/facility/food.php")
}
