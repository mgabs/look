import XCTest
@testable import LauncherLogic

final class QuickMathServiceTests: XCTestCase {
    func testUnitConversions() {
        // Data storage
        let resData = QuickMathService.evaluate("? 16 mb to gb")
        XCTAssertNotNil(resData)
        XCTAssertEqual(resData?.display, "0.0156 GB")

        let resData2 = QuickMathService.evaluate("1024 kb to mb")
        XCTAssertNotNil(resData2)
        XCTAssertEqual(resData2?.display, "1 MB")

        // Length
        let resLen = QuickMathService.evaluate("? 100 km to miles")
        XCTAssertNotNil(resLen)
        XCTAssertTrue(resLen?.display.contains("mi") == true)

        // Weight
        let resWeight = QuickMathService.evaluate("? 5 kg to lbs")
        XCTAssertNotNil(resWeight)
        XCTAssertTrue(resWeight?.display.contains("lbs") == true)

        // Temperature
        let resTemp = QuickMathService.evaluate("? 100 c to f")
        XCTAssertNotNil(resTemp)
        XCTAssertEqual(resTemp?.display, "212 °F")

        let resTemp2 = QuickMathService.evaluate("? 32 f to c")
        XCTAssertNotNil(resTemp2)
        XCTAssertEqual(resTemp2?.display, "0 °C")

        // Time
        let resTime = QuickMathService.evaluate("? 120 mins to hours")
        XCTAssertNotNil(resTime)
        XCTAssertEqual(resTime?.display, "2 hours")
    }

    func testCurrencyConversions() {
        let res = QuickMathService.evaluate("? 120 eur to usd")
        XCTAssertNotNil(res)
        XCTAssertTrue(res?.display.contains("USD") == true)
    }

    func testTimestampEvaluation() {
        let res = QuickMathService.evaluate("? timestamp 1712345678")
        XCTAssertNotNil(res)
        XCTAssertTrue(res?.display.contains("2024-04-05") == true)
        XCTAssertTrue(res?.subtitle.contains("1712345678") == true)

        let resNow = QuickMathService.evaluate("? timestamp now")
        XCTAssertNotNil(resNow)
        XCTAssertTrue(resNow?.subtitle.contains("UTC") == true)
    }
}
