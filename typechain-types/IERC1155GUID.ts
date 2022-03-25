/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import {
  BaseContract,
  BigNumber,
  BigNumberish,
  BytesLike,
  CallOverrides,
  ContractTransaction,
  Overrides,
  PopulatedTransaction,
  Signer,
  utils,
} from "ethers";
import { FunctionFragment, Result, EventFragment } from "@ethersproject/abi";
import { Listener, Provider } from "@ethersproject/providers";
import { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "./common";

export interface IERC1155GUIDInterface extends utils.Interface {
  contractName: "IERC1155GUID";
  functions: {
    "roleAssign(address,string)": FunctionFragment;
    "roleHas(address,string)": FunctionFragment;
    "roleRemove(address,string)": FunctionFragment;
  };

  encodeFunctionData(
    functionFragment: "roleAssign",
    values: [string, string]
  ): string;
  encodeFunctionData(
    functionFragment: "roleHas",
    values: [string, string]
  ): string;
  encodeFunctionData(
    functionFragment: "roleRemove",
    values: [string, string]
  ): string;

  decodeFunctionResult(functionFragment: "roleAssign", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "roleHas", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "roleRemove", data: BytesLike): Result;

  events: {
    "CaseCreated(uint256,address)": EventFragment;
    "RoleCreated(uint256,string)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "CaseCreated"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "RoleCreated"): EventFragment;
}

export type CaseCreatedEvent = TypedEvent<
  [BigNumber, string],
  { id: BigNumber; contractAddress: string }
>;

export type CaseCreatedEventFilter = TypedEventFilter<CaseCreatedEvent>;

export type RoleCreatedEvent = TypedEvent<
  [BigNumber, string],
  { id: BigNumber; role: string }
>;

export type RoleCreatedEventFilter = TypedEventFilter<RoleCreatedEvent>;

export interface IERC1155GUID extends BaseContract {
  contractName: "IERC1155GUID";
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IERC1155GUIDInterface;

  queryFilter<TEvent extends TypedEvent>(
    event: TypedEventFilter<TEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TEvent>>;

  listeners<TEvent extends TypedEvent>(
    eventFilter?: TypedEventFilter<TEvent>
  ): Array<TypedListener<TEvent>>;
  listeners(eventName?: string): Array<Listener>;
  removeAllListeners<TEvent extends TypedEvent>(
    eventFilter: TypedEventFilter<TEvent>
  ): this;
  removeAllListeners(eventName?: string): this;
  off: OnEvent<this>;
  on: OnEvent<this>;
  once: OnEvent<this>;
  removeListener: OnEvent<this>;

  functions: {
    roleAssign(
      account: string,
      role: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    roleHas(
      account: string,
      role: string,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    roleRemove(
      account: string,
      role: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;
  };

  roleAssign(
    account: string,
    role: string,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  roleHas(
    account: string,
    role: string,
    overrides?: CallOverrides
  ): Promise<boolean>;

  roleRemove(
    account: string,
    role: string,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  callStatic: {
    roleAssign(
      account: string,
      role: string,
      overrides?: CallOverrides
    ): Promise<void>;

    roleHas(
      account: string,
      role: string,
      overrides?: CallOverrides
    ): Promise<boolean>;

    roleRemove(
      account: string,
      role: string,
      overrides?: CallOverrides
    ): Promise<void>;
  };

  filters: {
    "CaseCreated(uint256,address)"(
      id?: BigNumberish | null,
      contractAddress?: null
    ): CaseCreatedEventFilter;
    CaseCreated(
      id?: BigNumberish | null,
      contractAddress?: null
    ): CaseCreatedEventFilter;

    "RoleCreated(uint256,string)"(
      id?: BigNumberish | null,
      role?: null
    ): RoleCreatedEventFilter;
    RoleCreated(id?: BigNumberish | null, role?: null): RoleCreatedEventFilter;
  };

  estimateGas: {
    roleAssign(
      account: string,
      role: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;

    roleHas(
      account: string,
      role: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    roleRemove(
      account: string,
      role: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    roleAssign(
      account: string,
      role: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;

    roleHas(
      account: string,
      role: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    roleRemove(
      account: string,
      role: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;
  };
}
