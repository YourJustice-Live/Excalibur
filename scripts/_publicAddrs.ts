//Track Addresses (Fill in present addresses to user existing deplopyment)
const publicAddr: any = {
  rinkeby:{
    // assocRepo: "0xfd5592B4604c5a422c507c4b116b51EE8e80E0C3", //V1.1    //DEPRECATED
    openRepo: "0x7b0AA37bCf5D231C13C920E0e372027919510fF9", //V2.0 (UUPS)
    ruleRepo: "0xa14C272e1D6BE9c89933e2Ad8560e83F945Ee407", //V1.0
  },
  mumbai:{
    openRepo: "0x7216B1ccA943f740794EC96263678dc91f230796",
    ruleRepo: "0x84AF36Bafb102A63A7d6239B4A4a3D76fB873823",
  },
  optimism:{
    openRepo: "",
    ruleRepo: "",
  },
  optimism_kovan:{
    openRepo: "0x8761b3E3bCDd243A063f18d5C24528C1400FA95B",
    ruleRepo: "",
  },
};

export default publicAddr;