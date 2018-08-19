pragma solidity ^0.4.24;

// import Open Zeppelin contract for Owner function authorization
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";

/** @title Media Gallery. */
contract MediaGallery is Ownable {

    //Author: Graham Jackson
    //Date: 27 August 2018
    //Version: MediaGallery v1.0 Rinkeby
    /*
    This contract provides the ability to create a library of media assets
    which are referenced via a hash and are meant to be stored/retrieved via 
    the inter-planetary file systme (IPFS).
    */

    bool public isStopped;      //State variabe used to stop/start the contract
    uint public mediaCounter;   //A count of the total media assets added to the contract

    //Each poster address consists of an array of MediaAsset structs
    //Used to store media assets, including the metadata associated with it, and to retrieve media
    struct MediaAsset {
        uint id;                //Unique identifier for a media asset
        string name;            //Name of added media asset 
        string description;     //Description of added media asset
        address author;         //Person who added the media assset
        uint createDate;        //Date and time the media asset was added via block.timestamp
        string tags;            //List of tags for added media asset
        string mediaHash;       //Multi-hash of the media to retrieve media from IPFS
        string mediaType;       //Type for media
        string extension;       //File Extension
    }

    //Database of Media assets. Each poster address has an array of MediaAssets
    mapping(address => MediaAsset[]) public mediaDatabase;

    //Event to log when a new media asset has been added
    event LogNewMediaAsset(
        uint indexed _id,       //Unique identifier for the added media asseet
        string _name,           //Name of added media asset
        address _author,        //Address of person added media asset
        uint _createDate,       //Date and time the media asset was added
        string _mediaHash,      //Multi-hash of the added media asset
        string _mediaType       //Type of the added media asset
    );

    //Modifier to prevent particular functions from being run during a stoppage
    modifier stoppedInEmergency {
        require(
            !isStopped,
            "The contract has been stopped"
        );
        _;
    }

    /** @dev Stops the contract.*/
    function stopContract() public onlyOwner {
        isStopped = true;
    }

    /** @dev Resume the contract.*/
    function resumeContract() public onlyOwner {
        isStopped = false;
    }

    /** @dev Add mew media asset and trigger associted event.
      * @param _name Name of the media asset.
      * @param _description Description of the media asset.
      * @param _mediaHash Multi-haash of the media asset.
      * @param _tags List of tags for media asset.
      * @param _mediaType File type of media asset.
      * @param _extension File extension of media asset.
    */
    function addMedia(
        string _name,
        string _description,
        string _mediaHash,
        string _tags,
        string _mediaType,
        string _extension
        ) public  stoppedInEmergency {
        //Store media asset information in memory
        MediaAsset memory currentMedia;
        /* 
        Timestamp of the current block in seconds since the epoch.
        Typically, it is not recommended to use the timestamp of a block
        because there is no way to cryptographically verify the timestamp
        and it can be manipulated by miners. However, in this case the
        timestamp is purely informational and is not used for any validation
        or action.
        */
        uint date = block.timestamp;

        currentMedia.id = mediaCounter;
        currentMedia.name = _name;
        currentMedia.description = _description;
        currentMedia.author = msg.sender;
        currentMedia.createDate = date;
        currentMedia.mediaHash = _mediaHash;
        currentMedia.tags = _tags;
        currentMedia.mediaType = _mediaType;
        currentMedia.extension = _extension;

        //Store the media asset in the database for the address of the sender
        mediaDatabase[msg.sender].push(currentMedia);

        //Emit the event for adding a media asset
        emit LogNewMediaAsset(
            mediaCounter,
            _name,
            msg.sender,
            date,
            _mediaHash,
            _mediaType
        );

        //Increment the media counter to track total
        mediaCounter++;
    }

    /** @dev Retrieve unique identifiers for media assets for a particular address.
      * @param _user Address to retrieve media identifiers for.
      * @return mediaAssetIds An array of media identifiers for provided address.
    */
    function getMediaByAddress(address _user) public view returns (uint[]) {
        //Check to see if the address has provided any media assets yet
        require(mediaDatabase[_user].length > 0, "No media found for this user");

        uint[] memory mediaAssetIds = new uint[](mediaDatabase[_user].length);

        uint numberOfMediaAssets = 0;

        for(uint i = 0; i < mediaDatabase[_user].length;  i++) {
            mediaAssetIds[numberOfMediaAssets] = mediaDatabase[_user][i].id;
            numberOfMediaAssets++;
        }
        return mediaAssetIds;
    }
}