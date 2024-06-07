// @generated by protoc-gen-es v1.8.0 with parameter "keep_empty_files=true,target=js+dts"
// @generated from file examples/proto_grpc/status.proto (package rpc, syntax proto3)
/* eslint-disable */
// @ts-nocheck

import type { Any, BinaryReadOptions, FieldList, JsonReadOptions, JsonValue, PartialMessage, PlainMessage } from "@bufbuild/protobuf";
import { Message, proto3 } from "@bufbuild/protobuf";

/**
 * @generated from message rpc.Status
 */
export declare class Status extends Message<Status> {
  /**
   * @generated from field: int32 code = 1;
   */
  code: number;

  /**
   * @generated from field: string message = 2;
   */
  message: string;

  /**
   * @generated from field: repeated google.protobuf.Any details = 3;
   */
  details: Any[];

  constructor(data?: PartialMessage<Status>);

  static readonly runtime: typeof proto3;
  static readonly typeName = "rpc.Status";
  static readonly fields: FieldList;

  static fromBinary(bytes: Uint8Array, options?: Partial<BinaryReadOptions>): Status;

  static fromJson(jsonValue: JsonValue, options?: Partial<JsonReadOptions>): Status;

  static fromJsonString(jsonString: string, options?: Partial<JsonReadOptions>): Status;

  static equals(a: Status | PlainMessage<Status> | undefined, b: Status | PlainMessage<Status> | undefined): boolean;
}
