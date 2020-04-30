pragma solidity ^0.5.17;


contract VerifiedSite {
    /*
		a data sturcture is used to save each site's detection information.
	*/
    struct Detection {
        address performer; // address of detection function performer.
        uint256 expireTime; // UNIX time format of detection expire time.
        bytes32 detectionTech; // detect approach of current detection.
        bytes32 detectionTechVersion; // version of detect approach.
        bool malicious; // true if site is malicious, false on the contray.
        bytes32 description; // extra information given by user.
    }

    /*
		current reward of the contract, set by requsetReview function.
		designed for improve contract users update information(detection).
	*/
    bytes32 public FQDN; // contract's Fully Qualified Domain Name.
    uint256 public totalDetections; // number of current sits's Detection(s).
    uint256 public numMaliciousDetections; // times that this site reported malicious.
    bool public reviewable; // state of this site is reviewable, change when initialization, requestReview and review.
    address payable ownerAddress; // Owner's address.
    address payable webAddress; // assume that every web has its own ethereum address.

    // mapping sturcture (Key -> Detection sturcture);
    mapping(uint256 => Detection) public detections;

    modifier onlyOwner {
        require(ownerAddress == msg.sender, "not owner");
        _;
    }

    modifier onlyRequester {
        require(webAddress == msg.sender, "not requester");
        _;
    }

    /*
		Contract initialization.
		Input:
		_FQDN: 					// contract's Fully Qualified Domain Name.
		_detectionTech: 		// number of current sits's Detection(s).
		_detectionTechVersion: 	// times that this site reported malicious.
		_malicious:				// true if site is malicious, false on the contray.
		_description:			// extra information given by user.
		_webAddress				// web's ethereum address
	*/

    constructor(
        bytes32 _FQDN,
        bytes32 _detectionTech,
        bytes32 _detectionTechVersion,
        bool _malicious,
        bytes32 _description,
        address payable _webAddress
    ) public {
        // init global states
        ownerAddress = msg.sender;
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
        webAddress = _webAddress;
        det.description = _description;

        if (_malicious == true) {
            numMaliciousDetections += 1;
        }
    }

    /*
		requestReview is a function that users can put their ether into thin contract and inprove
		other user's motivation to review(perform another detect).
	*/

    function requestReview(uint256 amount) public payable onlyRequester {
        require(msg.value == amount, "ether amount dismatch");
        // an request can only success when reviewable is false and donated ether between 0.01 and 1.
        if (reviewable == false) {
            // change review state
            reviewable = true;
        } else {
            // return donated ether with message.
            revert("Return ether");
        }
    }

    /*
		review is a function that can only performed when reviewable global variable and timestamp
		is not expired. Then user can update detections and collect reward. Use
		Checks-Effects-Interactions(CEI) pattern to avoid reentrancy.
	   	Input:
	   	_detectionTech: number of current sits's Detections.
		_detectionTechVersion: times that this site reported malicious.
		_malicious: true if site is malicious, false on the contray.
		_description: information given by function user.
	*/

    function review(
        bytes32 _detectionTech,
        bytes32 _detectionTechVersion,
        bool _malicious,
        bytes32 _description
    ) public onlyOwner {
        /* Checks
		   	Check reviewable global variable and timestamp is not expired, throw an exception if the condition is not met.
		   	* use by owner(contract constructor) only
		*/
        require(
            reviewable ||
                (block.timestamp >= detections[totalDetections].expireTime),
            "not reviewable"
        );
        /* Effects */
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
        reviewable = false;

        /* Interactions */
        ownerAddress.transfer(address(this).balance); // You get what you pay for!
    }

    function withdraw() public onlyRequester {
        webAddress.transfer(address(this).balance);
    }
}
