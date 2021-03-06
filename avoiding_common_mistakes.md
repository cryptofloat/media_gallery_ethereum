# Avoiding Common Mistakes
I took some simple steps to make sure I avoid common mistakes when it comes to the security of my MediaGallery contract.

The sections below describes the steps taken to mitigate against potential contract vulnerabilities. 

## 1. Logic Bugs
Simple programming mistakes can cause the contract to behave differently to its stated rules. 

I have mitigated against this risk by:

* Following Solidity coding standards and general coding best practices.
* Avoiding overly complex rules.
* Writing unit tests that cover all functions of my contract, including the happy path, and situations where exceptions will/can occur.
* Leveraging tools like Solidity Coverage to enesure I have tested relevant scenarios of my contract.

## 2. Poison Data
Contracts that accept user input that is stored or exposed to other users are vulnerable to being supplied with unanticipated input that causes problems for the contract or for other users of the contract. 

I have mitigated against this risk by:

* Limiting the length of user-supplied data such as the name, description, and tags for a media asset.
* Running unit tests for these scenarios - see e.g. "should throw an exception if the media name submitted is too long"...

## 3. Exposed Functions
It is easy to accidentally expose a contract function which was meant to be internal, or to omit protection on a function which was meant to be called only by priviledged accounts (e.g. by the creator). I made sure to mark every function appropriatley, and leverage tested libraries like Ownable by Open Zeppelin to control which functions can only be executed by the contract owner.

## 4. Exposed Secrets
All code and data on the blockchain is visible by anyone, even if not marked as "public" in Solidity.

I have mitigated against this risk by:

* Ensuring the MediaGallery contract does not rely on any secret information.

## 5. Denial of Service / Dust Spam
An attacker may cause inconvenience for other users by supplying the contract with data that is expensive to process, or by repeatedly carrying out actions that prevent others from interacting with the contract.

I have mitigated against this risk by:

* Limiting the length of user-supplied data such as the name, description, and tags for a media asset.

## 6. Block Timestamps/Hashes
Even without serious collusion, Ethereum miners have some limited ability to influence block timestamps and which transactions are chosen in a block.

We have mitigated against this risk by:

* Not using block hashes.
* Not leveraging block timestamps for critical contract logic.

## 7. Tx.Origin Problem
If a contract relies on Solidity 'tx.origin' to decide who the caller is (e.g. to know who to set the poster of media is), there's a danger that a malicious intermediary contract could make calls to the contract on behalf of the user (who presumably thought the malicious intermediary contract would do something else).

I have mitigated against this risk by:

* Not using tx.origin and instead msg.sender

## 8. Solid Code Coverage
The blockchain is immutable in the sense that a once approved transaction is going to stay. Since smart contract deployment happens through a transaction, this results in the inability to fix issues quickly. That is why having a reliable set of tests is so crucial.

I have added a tool called Solidity-Coverage in order to generate a report to understand how extensive my test coverage is for the MediaGallery contract.

The report for my test coverage can be found here: [Solidity Coverage Report](http://htmlpreview.github.io/?https://github.com/gjackson12/media_gallery_ethereum/blob/master/coverage/contracts/index.html)

## 9. Race Conditions
One of the major dangers of calling external contracts is that they can take over the control flow, and make changes to your data that the calling function wasn't expecting. This class of bug can take many forms, and both of the major bugs that led to the DAO's collapse were bugs of this sort.

I miitgated the risks of race conditions by:

* Not allowing more than one function at one time to change a shared state variable.
* No external contracts are calling functions on the MediaGallery contract.

## 10. Integer Overflow and Underflow

### 1.0 Overflow

If a balance reaches the maximum uint value (2^256) it will circle back to zero. In order to mitigate this from occuring I have limited the integers a user can impact to just the following: 

* Total number of media assets.
* Unique identifier for a media asset.

### 2.0 Underflow

I don't see a scenario where this would be a risk given the MediaGallery contract's use of integers.

## 11 Gas Limits

I have mitigated gas limit issues to the best of my ability by: 

* Not looping over arrays of an un-determined length.
* I validate the length of data inputted by users.