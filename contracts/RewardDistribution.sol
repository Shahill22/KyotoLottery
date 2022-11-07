// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
         This contract is intended to be handled by a masterchef contract. 
*/

contract RewardDistribution is Ownable {
    using SafeMath for uint256;
    using Math for uint256;
    using SafeERC20 for IERC20;

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 accRewardTokenPerShare; // Accumulated Rewards per share
    }

    // Info of each pool.
    mapping(uint16 => PoolInfo) public poolInfo;
    // Pids of pools added from masterchef
    uint16[] public poolPids;
    // Info of each user that stakes LP tokens.
    mapping(uint16 => mapping(address => UserInfo)) public userInfo;
    // Reward tokens distributed per block
    uint128 public rewardPerBlock;
    // Reward token from fees to Liquidity providers
    IERC20 public immutable rewardToken;
    // Rewards already assigned to be distributed
    uint256 public assignedRewards;
    // Masterchef
    address public immutable masterchef;



    constructor(
        IERC20 _rewardToken,
        address _masterchef,
       
    ) {
        rewardToken = _rewardToken;
        masterchef = _masterchef;
       
    }

    modifier onlyMasterchef() {
        require(msg.sender == masterchef, "You are not the masterchef");
        _;
    }

    modifier onlyOwnerOrMasterchef() {
        require(msg.sender == masterchef || msg.sender == owner());
        _;
    }

    mapping(uint256 => bool) public poolExistence;
    modifier nonDuplicated(uint256 _pid) {
        require(poolExistence[_pid] == false, "nonDuplicated: duplicated");
        _;
    }

    /// Add a new lp to the pool. Can only be called by the owner.
    function add(IERC20 _lpToken, uint16 _pid)
        external
        onlyOwnerOrMasterchef
        nonDuplicated(_pid)
    {
        _massUpdatePools();
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        poolExistence[_pid] = true;
        poolPids.push(_pid);
        poolInfo[_pid] = (
            PoolInfo({
                lpToken: _lpToken,
                accRewardTokenPerShare: 0
            })
        );
    }

    ///  Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {
        if (_to <= endBlockRewards) {
            return _to.sub(_from);
        } else if (_from >= endBlockRewards) {
            return 0;
        } else {
            return endBlockRewards.sub(_from);
        }
    }

  


    /// Update reward variables for all pools. 
    function _massUpdatePools() private {
        uint256 length = poolPids.length;
        for (uint16 pid = 0; pid < length; pid++) {
            _updatePool(poolPids[pid]);
        }
    }

    /// @param _to address to send reward token to
    /// @param _amount value of reward token to transfer
    function safeTransferReward(address _to, uint256 _amount) internal {
        rewardToken.safeTransfer(_to, _amount);
    }

    /// Increment balance into the contract to calculate and earn rewards
    /// It assumes that there is no fee involved. It's, the masterchef should send the amount after fees.
    /// @param _amount The amount to increment the balance
    /// @param _pid Pool identifier
    function incrementBalance(
        uint16 _pid,
        uint256 _amount,
        address _user
    ) external onlyMasterchef {
        require(poolExistence[_pid], "pool not found");
        require(
            _amount > 0,
            "IncrementBalance error: amount should be more than zero."
        );
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        _updatePool(_pid);
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accRewardTokenPerShare).div(
            1e18
        );
       
    }

    /// Reduce balance into the contract
    /// @param _amount The amount to reduce the balance
    /// @param _pid Pool identifier
    function reduceBalance(
        uint16 _pid,
        uint256 _amount,
        address _user
    ) external onlyMasterchef {
        require(
            _amount > 0,
            "ReduceBalance error: amount should be more than zero."
        );
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        _updatePool(_pid);
        if (user.amount < _amount) {
            _amount = user.amount;
        }
        if (_amount == 0) {
            return;
        }
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accRewardTokenPerShare).div(
            1e18
        );
        
    }


    /// Obtain the reward balance of this contract.
    ///  Returns reward balance of this contract.
    function rewardBalance() public view returns (uint256) {
        return rewardToken.balanceOf(address(this));
    }

    /* Owner Functions */

    /// @dev Deposit new reward to be distrivuted.
    function depositRewards(uint256 _newRewards) external onlyOwner {
        rewardToken.safeTransferFrom(msg.sender, address(this), _newRewards);
        _massUpdatePools();
        updateRewardPerBlock();
    }
    
}
