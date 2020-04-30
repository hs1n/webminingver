pragma solidity ^0.4.0-^0.5.6;
contract VerifiedSite {
	
	/*
		a data sturcture is used to save each site's detection information.
	*/
	struct Detection {
		address performer; 		// address of detection function performer.
		uint expireTime; 		// UNIX time format of detection expire time.
		bytes32 detectionTech;		// detect approach of current detection.
		bytes32 detectionTechVersion;	// version of detect approach.
		bool malicious;			// true if site is malicious, false on the contray.
		bytes32 description;		// extra information given by user.
	}
	
	/* current reward of the contract, set by requsetReview function.
	   designed for improve contract users update information(detection).
	*/
	uint bounty;
	
	bytes32 public FQDN;  			// contract's Fully Qualified Domain Name.
	uint public totalDetections;		// number of current sits's Detection(s).
	uint public numMaliciousDetections;	// times that this site reported malicious.
	bool public reviewable;			// state of this site is reviewable, change when initialization, requestReview and review.
	
	// mapping sturcture (Key -> Detection sturcture);
	mapping (uint => Detection) public detections;

	/* contract initialization.
	   input _FQDN: 			// contract's Fully Qualified Domain Name.
		 _detectionTech: 		// number of current sits's Detection(s).
		 _detectionTechVersion: 	// times that this site reported malicious.
		 _malicious:			// true if site is malicious, false on the contray.
		 _description:			// extra information given by user.
	*/
	constructor(bytes32 _FQDN, bytes32 _detectionTech, bytes32 _detectionTechVersion, bool _malicious, bytes32 _description) public {
		// init global variables
		FQDN = _FQDN;
		totalDetections = 0;
		reviewable = false;
		
		// create new Detection object.
		Detection storage det = detections[totalDetections++];
		det.performer = msg.sender;
		det.expireTime = block.timestamp + 86400; // expiredTime increase 86400 second(1 Day).
		det.detectionTech = _detectionTech;
		det.detectionTechVersion = _detectionTechVersion;
		det.malicious = _malicious;
		if (_malicious == true) {
		    numMaliciousDetections += 1;
		}
		det.description = _description;
	}
	
	/* requestReview is a function that users can put their ether into thin contract and inprove other user's motivation to
			 review(perform another detect).
	*/
	function requestReview() payable public {
		// an request can only success when reviewable is false and donated ether between 0.01 and 1.
		if (reviewable == false && (msg.value <= 100000000000000000 && msg.value >= 1000000000000000)) {
			// increase bounty by donated amount of ether.
			bounty += msg.value;
			// change review state
			reviewable = true;
		} else {
			// return donated ether with message.
			revert("Return ether");
		}
	}
	/* review is a function that can only performed when reviewable global variable and timestamp is not expired. Then user can
		  update detections and collect reward(bounty).
		  Use Checks-Effects-Interactions(CEI) pattern to avoid reentrancy.
	   input _detectionTech: number of current sits's Detections.
		 _detectionTechVersion: times that this site reported malicious.
		 _malicious: true if site is malicious, false on the contray.
		 _description: information given by function user.
	*/
	function review(bytes32 _detectionTech, bytes32 _detectionTechVersion, bool _malicious, bytes32 _description) public {
		/* Checks 
		   Check reviewable global variable and timestamp is not expired, throw an exception if the condition is not met.
		*/
		require(reviewable || (block.timestamp >= detections[totalDetections].expireTime)); 
		
		/* Effects */
		// Same as Line 43-52
		Detection memory det = detections[totalDetections++];
		det.performer = msg.sender;
		det.expireTime = block.timestamp + 86400;
		det.detectionTech = _detectionTech;
		det.detectionTechVersion = _detectionTechVersion;
		det.malicious = _malicious;
		if (_malicious == true) {
		    numMaliciousDetections += 1;
		}
		det.description = _description;
		
		// change states
		uint256 share = bounty;		// Create temp variable to save current bounty amount.
		bounty = 0;
		reviewable = false;

		/* Interactions */
    		msg.sender.transfer(share);	// You get what you pay for!
	}
}
