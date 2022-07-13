//Track Addresses (Fill in present addresses to prevent new deplopyment)
const contractAddr: any = {
  rinkeby: {
      config:"0xA888d7f44638AEEBA9048Ca08bCF83a23e9f58dc",  //D2.1
      game:"0x4650e8FC59AbfD38B90712501225Fd19562C97AC",  //D2.91
      reaction:"0xF1326573800a70bbeDF360eCF6cdfCbE20459945",  //D2.8
      hub:"0xadE0EE8E93bC6EeB87c7c5279B36eA7977fCAF96", //D4.6 (Proxy)
      avatar:"0x0665dfc970Bd599e08ED6084DC12B2dD028cC416",  //D2.8 (Proxy)
      history:"0xD7ab715a2C1e5b450b54B1E3cE5136D755c715B8", //D4.4 (Proxy)
  },
  mumbai:{
    config: "0xbf4340F03E4B73d11aa0C6F63E8E4b0898d98c39",
    game: "0x1Bf1d285b5414e94227b1708C51A5CaD18496693",
    reaction: "0x501C45437a699827992667C3b032ee08FDbaD4f3",
    hub: "0xC46971d2a76DeC2DB76554c12eF07A0B2A407451",
    avatar: "0x29fEA694c32B51Ea283F7952f066Da3e12f33375",
    history: "0x695b590Dc9455299f349BCC4252650237D586512",
  },
  optimism:{
  },
  optimism_kovan:{
  },
};

export default contractAddr;