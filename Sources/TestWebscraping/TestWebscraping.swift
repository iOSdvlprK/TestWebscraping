import Foundation
import SwiftSoup
import Alamofire

@main
public struct TestWebscraping {
  public private(set) var text = "Hello, World!"
  static let urlText = "https://www.google.com"
  static let urlText2 = "https://movie.naver.com"
  static let someJSON = "https://dummyjson.com/products/1"
  static var check = 0

  public static func main() {
    print(TestWebscraping().text)

    let webtest = TestWebscraping()
    
    webtest.alamofire(urlText2) { text in
      print(text)
      print("--- Alamofire done #3 ---")
      check += 1
      if check == 2 { exit(0) }
    }
    webtest.urlsession(urlText2) { text in
      print(text)
      print("--- URLSession done #3 ---")
      check += 1
      if check == 2 { exit(0) }
    }
    webtest.swiftsoup()
    
    dispatchMain()
  }

  public func alamofire(_ url: String, completion: @escaping (String) -> Void) {
    let headers: HTTPHeaders = [
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"
    ]
    AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseData { dataResponse in
        if let err = dataResponse.error {
            print("Failed to connect to Google", err)
            return
        }
        guard let data = dataResponse.data else { return }
        debugPrint(data)
        guard let text = String(data: data, encoding: .utf8) else {
            print("=== no data from Alamofire ===")
            return
        }
        completion(text)
        print("--- Alamofire done #1 ---")
    }
    // Below code does not work on various normal sites without providing the above custom user agent data.
    // AF.request(url).responseData { dataResponse in 
    //   if let err = dataResponse.error {
    //     print("Failed to connect to Google", err)
    //     return
    //   }
    //   guard let data = dataResponse.data else { return }
    //   debugPrint(data)
    //   guard let text = String(data: data, encoding: .utf8) else { 
    //     print("=== no data from Alamofire ===")
    //     return 
    //   }
    //   completion(text)
    //   print("--- Alamofire done #1 ---")
    // }
    print("--- Alamofire done #2 ---")
  }

  public func urlsession(_ url: String, completion: @escaping (String) -> Void) {
    guard let url = URL(string: url) else { return }
    let session = URLSession(configuration: .default)
    session.dataTask(with: url) { data, response, error in
      guard let data = data, error == nil else { return }
      debugPrint(data)
      guard let text = String(data: data, encoding: .utf8) else {
        print("=== no data from URLSession ===")
        return
      }
      completion(text)
      print("--- URLSession done #1 ---")
    }.resume()
    print("--- URLSession done #2 ---")
  }

  public func swiftsoup() {
    do {
      let html: String = "<p>An <a href='http://example.com/'><b>example</b></a> link.</p>"
      let doc: Document = try SwiftSoup.parse(html)
      let link: Element = try doc.select("a").first()!
      
      let text: String = try doc.body()!.text() // "An example link."
      print(text)
      let linkHref: String = try link.attr("href") // "http://example.com/"
      print(linkHref)
      let linkText: String = try link.text() // "example"
      print(linkText)
      let linkOuterH: String = try link.outerHtml() // "<a href="http://example.com/"><b>example</b></a>"
      print(linkOuterH)
      let linkInnerH: String = try link.html() // "<b>example</b>"
      print(linkInnerH)
    } catch Exception.Error(let type, let message) {
        print(type, message)
    } catch {
        print("error")
    }
    print("--- SwiftSoup done ---")
  }
}