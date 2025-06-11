class CityAPI {
  final String name;
  final String url;

  CityAPI({required this.name, required this.url});
}

class ApiConfig {
  // 定義各縣市的停車費查詢API
  static final Map<String, CityAPI> cityApis = {
    "臺北市": CityAPI(
      name: "臺北市",
      url: "https://trafficapi.pma.gov.taipei/Parking/PayBill/CarID/{CarID}/CarType/{CarType}",
    ),
    "新北市": CityAPI(
      name: "新北市",
      url: "https://trafficapi.traffic.ntpc.gov.tw/Parking/PayBill/CarID/{CarID}/CarType/{CarType}",
    ),
    "基隆市": CityAPI(
      name: "基隆市",
      url: "https://park.klcg.gov.tw/TrafficPayBill/Parking/PayBill/CarID/{CarID}/CarType/{CarType}",
    ),
    "宜蘭縣": CityAPI(
      name: "宜蘭縣",
      url: "https://billparking.e-land.gov.tw/Parking/PayBill/carid/{carid}/cartype/{cartype}",
    ),
    "桃園市": CityAPI(
      name: "桃園市",
      url: "https://bill-epark.tycg.gov.tw/Parking/PayBill/CarID/{CarID}/CarType/{CarType}",
    ),
    "新竹市": CityAPI(
      name: "新竹市",
      url: "https://his.futek.com.tw:5443/TrafficPayBill/Parking/PayBill/CarID/{CarID}/CarType/{CarType}",
    ),
    "新竹縣": CityAPI(
      name: "新竹縣",
      url: "https://hcpark.hchg.gov.tw/NationalParkingPayBillInquiry/Parking/PayBill/CarID/{CarID}/CarType/{CarType}",
    ),
    "苗栗縣": CityAPI(
      name: "苗栗縣",
      url: "https://miaoliparking.jotangi.com.tw/TrafficPayBill/Parking/PayBill/CarID/{CarID}/CarType/{CarType}",
    ),
    "臺中市": CityAPI(
      name: "臺中市",
      url: "http://tcparkingapi.taichung.gov.tw:8081/NationalParkingPayBillInquiry.Api/Parking/PayBill/CarID/{CarID}/CarType/{CarType}",
    ),
    "彰化縣": CityAPI(
      name: "彰化縣",
      url: "https://chpark.chcg.gov.tw/TrafficPayBill/Parking/PayBill/CarID/{CarID}/CarType/{CarType}",
    ),
    "南投縣": CityAPI(
      name: "南投縣",
      url: "https://parking.nantou.gov.tw/TrafficPayBill/Parking/PayBill/CarID/{CarID}/CarType/{CarType}",
    ),
    "雲林縣": CityAPI(
      name: "雲林縣",
      url: "https://parking.yunlin.gov.tw/TrafficPayBill/Parking/PayBill/CarID/{CarID}/CarType/{CarType}",
    ),
    "嘉義市": CityAPI(
      name: "嘉義市",
      url: "https://parking.chiayi.gov.tw/cypark/api/Parking/PayBill/CarID/{CarID}/CarType/{CarType}",
    ),
    "嘉義縣": CityAPI(
      name: "嘉義縣",
      url: "https://8voc0wuf1g.execute-api.ap-southeast-1.amazonaws.com/default/chiayi/Parking/PayBill/CarID/{CarID}/CarType/{CarType}",
    ),
    "臺南市": CityAPI(
      name: "臺南市",
      url: "https://parkingbill.tainan.gov.tw/Parking/Paybill/CarID/{CarID}/CarType/{CarType}",
    ),
    "高雄市": CityAPI(
      name: "高雄市",
      url: "https://kpp.tbkc.gov.tw/TrafficPayBill/Parking/PayBill/CarID/{carid}/CarType/{cartype}",
    ),
    "屏東縣": CityAPI(
      name: "屏東縣",
      url: "https://8voc0wuf1g.execute-api.ap-southeast-1.amazonaws.com/default/pingtung/Parking/PayBill/CarID/{CarID}/CarType/{CarType}",
    ),
    "花蓮縣": CityAPI(
      name: "花蓮縣",
      url: "https://hl.parchere.com.tw/TrafficPayBill/Parking/PayBill/CarID/{CarID}/CarType/{CarType}",
    ),
    "台東縣": CityAPI(
      name: "台東縣",
      url: "https://tt.guoyun.com.tw/TrafficPayBill/Parking/PayBill/CarID/{CarID}/CarType/{CarType}",
    ),
    "金門縣": CityAPI(
      name: "金門縣",
      url: "https://km.guoyun.com.tw/TrafficPayBill/Parking/PayBill/CarID/{CarID}/CarType/{CarType}",
    ),
  };

  // 縣市順序 (從北到南再到東部及離島)
  static final List<String> cityOrder = [
    "臺北市", "新北市", "基隆市", "宜蘭縣", "桃園市", "新竹市", "新竹縣", "苗栗縣",
    "臺中市", "彰化縣", "南投縣", "雲林縣", "嘉義市", "嘉義縣", "臺南市", "高雄市", "屏東縣",
    "花蓮縣", "台東縣", "金門縣"
  ];
}