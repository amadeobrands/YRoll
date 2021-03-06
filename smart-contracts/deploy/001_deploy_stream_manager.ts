import {BuidlerRuntimeEnvironment, DeployFunction,} from "@nomiclabs/buidler/types";
import {STREAM_MANAGER} from "./constants";

const func: DeployFunction = async function (bre: BuidlerRuntimeEnvironment) {
    const {deployments, getNamedAccounts} = bre;
    const {deploy} = deployments;

    const {deployer} = await getNamedAccounts();

    await deploy(STREAM_MANAGER, {
        from: deployer,
        log: true,
    });
};

export default func;

func.tags = [STREAM_MANAGER];