# 🔐 Core Smart Contract Vulnerabilities & Foundry PoC Portfolio

This section documents my hands-on security analysis and exploit reproduction (PoC) for high-risk smart contract vulnerabilities commonly seen in DeFi audits.

---

## 📋 Table of Contents
1. [Reentrancy Vulnerability](#1-reentrancy-vulnerability)
2. [Oracle Price Manipulation](#2-oracle-price-manipulation)
3. [Signature Replay Attack](#3-signature-replay-attack)
4. [Unprotected Initialization](#4-unprotected-initialization)
5. [Missing Access Control](#5-missing-access-control)

---

### 1. Reentrancy Vulnerability
* **Severity**: Critical 🔴
* **Vulnerability Description**: 
  The vulnerable contract violated the **Checks-Effects-Interactions (CEI)** pattern by transferring ETH via `.call{value: amount}("")` *before* updating the user's balance (`balances[msg.sender] = 0`). 
* **Attack Vector**: 
  An attacker deployed a malicious contract with a `receive()` fallback function that recursively re-called the `withdraw()` method before the state could be updated, completely draining the contract balance.
* **Remediation**: 
  * Enforce the CEI pattern (update state variables first).
  * Implement OpenZeppelin's `ReentrancyGuard` modifier (`nonReentrant`).

---

### 2. Oracle Price Manipulation
* **Severity**: Critical 🔴
* **Vulnerability Description**: 
  The lending protocol relied directly on instantaneous spot reserves from a single Uniswap V2 pair (`getReserves()`) to calculate collateral value.
* **Attack Vector**: 
  An attacker utilized a flash loan to inject a massive amount of liquidity, temporarily unbalancing the pool ratio and distorting the spot price fed into the lending protocol, allowing them to borrow assets with worthless collateral.
* **Remediation**: 
  * Avoid using spot prices from single automated market maker (AMM) pools.
  * Integrate decentralized oracles like Chainlink or use Time-Weighted Average Price (TWAP).

---

### 3. Signature Replay Attack
* **Severity**: High 🟠
* **Vulnerability Description**: 
  Off-chain signature verification (`ecrecover`) lacked a unique incremental `Nonce` and `ChainId` check.
* **Attack Vector**: 
  A valid signature captured by an attacker could be repeatedly submitted to drain funds or replayed across different blockchain networks.
* **Remediation**: 
  * Introduce an auto-incrementing `nonce` mapping for each user and consume it upon successful execution.
  * Implement EIP-712 standard for structured data signing.

---

### 4. Unprotected Initialization
* **Severity**: Critical 🔴
* **Vulnerability Description**: 
  In a proxy upgrade pattern, the implementation contract's `initialize()` function lacked access control or an initialization lock.
* **Attack Vector**: 
  An attacker could front-run the deployment transaction, invoke `initialize()`, and seize the `owner` privilege of the entire protocol.
* **Remediation**: 
  * Use OpenZeppelin's `initializer` modifier to ensure the initialization function can only be executed once.

---

### 5. Missing Access Control
* **Severity**: High 🟠
* **Vulnerability Description**: 
  Critical parameter-updating functions (e.g., changing fee recipients) lacked proper modifier protection like `onlyOwner`.
* **Attack Vector**: 
  Any external unprivileged account could invoke the function and hijack protocol revenues.
* **Remediation**: 
  * Apply strict role-based access control (RBAC) or standard `onlyOwner` modifiers.
