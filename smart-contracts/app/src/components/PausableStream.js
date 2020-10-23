import React, {useEffect, useState} from "react";

import {constants} from "ethers";

const PausableStream = (props) => {
  let {streamId, streamManager, provider, time} = props;
  const [stream, setStream] = useState(undefined);
  const [watcher, setWatcher] = useState(undefined);

  useEffect(() => {
    const watcher = setInterval(() => {
      streamManager.getPausableStream(streamId).then(setStream);
    }, 5000);

    setWatcher(watcher);
    return () => clearInterval(watcher);
  }, [streamId, provider, streamManager]);

  if (undefined === watcher || undefined === stream) {
    return <div>Loading..</div>;
  }

  console.log(stream);

  return (
    <div>
      <p> {stream.isRunning ? "running" : "not"}</p>
      <p>
        {"Start time: "}
        {new Date(stream.startTime.mul(1000).toNumber()).toTimeString()}{" "}
        {new Date(stream.startTime.mul(1000).toNumber()).toDateString()}
      </p>
      <p>
        {"Current time: "}
        {new Date(time * 1000).toTimeString()}
        {new Date(time * 1000).toDateString()}
      </p>
      <p>Deposit: {stream.deposit.toString()}</p>
      <p>Balance accrued: {stream.balanceAccrued.toNumber()}</p>
      <p>Time running: {stream.durationElapsed.toString()}</p>
    </div>
  );
};

export default PausableStream;
