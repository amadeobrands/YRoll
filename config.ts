import * as dotenv from "dotenv";

dotenv.config();

export default {
  privateKey: process.env.PRIVATE_KEY ?? "h",
  etherScanKey: process.env.ETHERSCAN_API_KEY ?? "",
  infuraKey: process.env.INFURA_API_KEY ?? "",
};
