pragma solidity ^0.4.0-^0.5.6;
contract VerifiedSite {

	struct Detection {
		address performer; // address of detection performer
		uint expireTime; //expire time: UNIX format
		bytes32 detectionTech;
		bytes32 detectionTechVersion;
		bool malicious;
		bytes32 description;
	}
	uint bounty;

	bytes32 public FQDN;
	uint public totalDetections;
	uint public numMaliciousDetections;
	bool public reviewable;

	mapping (uint => Detection) public detections;

	constructor(bytes32 _FQDN, bytes32 _detectionTech, bytes32 _detectionTechVersion, bool _malicious, bytes32 _description) public {
		FQDN = _FQDN;
		totalDetections = 0;
		reviewable = false;

		Detection storage det = detections[totalDetections++];
		det.performer = msg.sender;
		det.expireTime = block.timestamp + 86400;
		det.detectionTech = _detectionTech;
		det.detectionTechVersion = _detectionTechVersion;
		det.malicious = _malicious;
		if (_malicious == true) {
		    numMaliciousDetections += 1;
		}
		det.description = _description;
	}

	function requestReview() payable public {
		if (reviewable == false && (msg.value <= 100000000000000000 && msg.value >= 1000000000000000)) { // 0.01~1 ether
			bounty += msg.value;
			reviewable = true;
		} else {
			revert("Return ether");
		}
	}

	function review(bytes32 _detectionTech, bytes32 _detectionTechVersion, bool _malicious, bytes32 _description) public {
		/* active when web adm call requestReview()
		   using Checks-Effects-Interactions pattern to avoid reentrancy */

		/* Checks */
		require(reviewable || (block.timestamp >= detections[totalDetections].expireTime));

		/* Effects */
		Detection storage det = detections[totalDetections++];
		det.performer = msg.sender;
		det.expireTime = block.timestamp + 86400;
		det.detectionTech = _detectionTech;
		det.detectionTechVersion = _detectionTechVersion;
		det.malicious = _malicious;
		if (_malicious == true) {
		    numMaliciousDetections += 1;
		}
		det.description = _description;

		uint256 share = bounty;
		bounty = 0;
		reviewable = false;

		/* Interactions */
    msg.sender.transfer(share);
	}
}
