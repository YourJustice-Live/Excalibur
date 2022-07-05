//Track Addresses (Fill in present addresses to prevent new deplopyment)
const contractAddr: any = {
  rinkeby: {
      config:"0xA888d7f44638AEEBA9048Ca08bCF83a23e9f58dc",  //D2.1
      jurisdiction:"0x4650e8FC59AbfD38B90712501225Fd19562C97AC",  //D2.91
      case:"0xF1326573800a70bbeDF360eCF6cdfCbE20459945",  //D2.8
      hub:"0xadE0EE8E93bC6EeB87c7c5279B36eA7977fCAF96", //D4.6 (Proxy)
      avatar:"0x0665dfc970Bd599e08ED6084DC12B2dD028cC416",  //D2.8 (Proxy)
      history:"0xD7ab715a2C1e5b450b54B1E3cE5136D755c715B8", //D4.4 (Proxy)
  },
  mumbai:{
    config: "0x1F2c31D5034F27A4352Bc6ca0fc72cdC32809808", // D2.1
    jurisdiction: "0x57d1469c53Bb259Dc876A274ADd329Eb703Ab286", // D2.91
    case: "0xED7621062a097f95183edC753e185B4f75d4B637", // D2.8
    hub: "0x47307dEBB584C680E51dAFb167622ce9633c2Acf", // D4.6 (Proxy)
    avatar: "0xFe61dc25C3B8c3F990bCea5bb901704B2a8b9Bd2", // D2.8 (Proxy)
    history: "0x95BD98a656C907fC037aF87Ea740fD94188Cd65f", // D4.4 (Proxy)
  },
  optimism:{
  },
  optimism_kovan:{
  },
};

export default contractAddr;