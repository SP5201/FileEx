(*
 * Copyright (c) 2020 Vacing Fang <vacingfang@tencent.com>
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 *)

(**
 * @file
 * DOVI configuration
 *)

(*
 * FFVCL - Delphi FFmpeg VCL Components
 * http://www.DelphiFFmpeg.com
 *
 * Original file: libavutil/dovi_meta.h
 * Ported by CodeCoolie@CNSW 2023/11/28 -> $Date:: 2024-01-17 #$
 *)

(*
FFmpeg Delphi/Pascal Headers and Examples License Agreement

A modified part of FFVCL - Delphi FFmpeg VCL Components.
Copyright (c) 2008-2024 DelphiFFmpeg.com
All rights reserved.
http://www.DelphiFFmpeg.com

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

This source code is provided "as is" by DelphiFFmpeg.com without
warranty of any kind, either expressed or implied, including but not
limited to the implied warranties of merchantability and/or fitness
for a particular purpose.

Please also notice the License agreement of FFmpeg libraries.
*)

unit libavutil_dovi_meta;

interface

{$I CompilerDefines.inc}

uses
  libavutil_rational,
  FFTypes;

{$I libversion.inc}

(*
 * DOVI configuration
 * ref: dolby-vision-bitstreams-within-the-iso-base-media-file-format-v2.1.2
        dolby-vision-bitstreams-in-mpeg-2-transport-stream-multiplex-v1.2
 * @code
 * uint8_t  dv_version_major, the major version number that the stream complies with
 * uint8_t  dv_version_minor, the minor version number that the stream complies with
 * uint8_t  dv_profile, the Dolby Vision profile
 * uint8_t  dv_level, the Dolby Vision level
 * uint8_t  rpu_present_flag
 * uint8_t  el_present_flag
 * uint8_t  bl_present_flag
 * uint8_t  dv_bl_signal_compatibility_id
 * @endcode
 *
 * @note The struct must be allocated with av_dovi_alloc() and
 *       its size is not a part of the public ABI.
 *)
type
  PAVDOVIDecoderConfigurationRecord = ^TAVDOVIDecoderConfigurationRecord;
  TAVDOVIDecoderConfigurationRecord = record
    dv_version_major: Byte;
    dv_version_minor: Byte;
    dv_profile: Byte;
    dv_level: Byte;
    rpu_present_flag: Byte;
    el_present_flag: Byte;
    bl_present_flag: Byte;
    dv_bl_signal_compatibility_id: Byte;
  end;

(**
 * Allocate a AVDOVIDecoderConfigurationRecord structure and initialize its
 * fields to default values.
 *
 * @return the newly allocated struct or NULL on failure
 *)
function av_dovi_alloc(size: PSize_t): PAVDOVIDecoderConfigurationRecord; cdecl; external AVUTIL_LIBNAME name _PU + 'av_dovi_alloc';

(**
 * Dolby Vision RPU data header.
 *
 * @note sizeof(AVDOVIRpuDataHeader) is not part of the public ABI.
 *)
type
  PAVDOVIRpuDataHeader = ^TAVDOVIRpuDataHeader;
  TAVDOVIRpuDataHeader = record
    rpu_type: Byte;
    rpu_format: Word;
    vdr_rpu_profile: Byte;
    vdr_rpu_level: Byte;
    chroma_resampling_explicit_filter_flag: Byte;
    coef_data_type: Byte; (* informative, lavc always converts to fixed *)
    coef_log2_denom: Byte;
    vdr_rpu_normalized_idc: Byte;
    bl_video_full_range_flag: Byte;
    bl_bit_depth: Byte; (* [8, 16] *)
    el_bit_depth: Byte; (* [8, 16] *)
    vdr_bit_depth: Byte; (* [8, 16] *)
    spatial_resampling_filter_flag: Byte;
    el_spatial_resampling_filter_flag: Byte;
    disable_residual_flag: Byte;
  end;

  TAVDOVIMappingMethod = (
    AV_DOVI_MAPPING_POLYNOMIAL = 0,
    AV_DOVI_MAPPING_MMR = 1
  );

(**
 * Coefficients of a piece-wise function. The pieces of the function span the
 * value ranges between two adjacent pivot values.
 *)
const
  AV_DOVI_MAX_PIECES = 8;
type
  TAVDOVIReshapingCurve = record
    num_pivots: Byte;                         (* [2, 9] *)
    pivots: array[0..AV_DOVI_MAX_PIECES] of Word;    (* sorted ascending *)
    mapping_idc: array[0..AV_DOVI_MAX_PIECES - 1] of TAVDOVIMappingMethod;
    (* AV_DOVI_MAPPING_POLYNOMIAL *)
    poly_order: array[0..AV_DOVI_MAX_PIECES - 1] of Byte;     (* [1, 2] *)
    poly_coef: array[0..AV_DOVI_MAX_PIECES - 1, 0..2] of Int64;   (* x^0, x^1, x^2 *)
    (* AV_DOVI_MAPPING_MMR *)
    mmr_order: array[0..AV_DOVI_MAX_PIECES - 1] of Byte;      (* [1, 3] *)
    mmr_constant: array[0..AV_DOVI_MAX_PIECES - 1] of Int64;
    mmr_coef: array[0..AV_DOVI_MAX_PIECES - 1, 0..2(* order - 1 *), 0..6] of Int64;
  end;

  TAVDOVINLQMethod = (
    AV_DOVI_NLQ_NONE = -1,
    AV_DOVI_NLQ_LINEAR_DZ = 0
  );

(**
 * Coefficients of the non-linear inverse quantization. For the interpretation
 * of these, see ETSI GS CCM 001.
 *)
  TAVDOVINLQParams = record
    nlq_offset: Word;
    vdr_in_max: UInt64;
    (* AV_DOVI_NLQ_LINEAR_DZ *)
    linear_deadzone_slope: UInt64;
    linear_deadzone_threshold: UInt64;
  end;

(**
 * Dolby Vision RPU data mapping parameters.
 *
 * @note sizeof(AVDOVIDataMapping) is not part of the public ABI.
 *)
  PAVDOVIDataMapping = ^TAVDOVIDataMapping;
  TAVDOVIDataMapping = record
    vdr_rpu_id: Byte;
    mapping_color_space: Byte;
    mapping_chroma_format_idc: Byte;
    curves: array[0..2] of TAVDOVIReshapingCurve; (* per component *)

    (* Non-linear inverse quantization *)
    nlq_method_idc: TAVDOVINLQMethod;
    num_x_partitions: Cardinal;
    num_y_partitions: Cardinal;
    nlq: array[0..2] of TAVDOVINLQParams; (* per component *)
  end;

(**
 * Dolby Vision RPU colorspace metadata parameters.
 *
 * @note sizeof(AVDOVIColorMetadata) is not part of the public ABI.
 *)
  PAVDOVIColorMetadata = ^TAVDOVIColorMetadata;
  TAVDOVIColorMetadata = record
    dm_metadata_id: Byte;
    scene_refresh_flag: Byte;

    (**
     * Coefficients of the custom Dolby Vision IPT-PQ matrices. These are to be
     * used instead of the matrices indicated by the frame's colorspace tags.
     * The output of rgb_to_lms_matrix is to be fed into a BT.2020 LMS->RGB
     * matrix based on a Hunt-Pointer-Estevez transform, but without any
     * crosstalk. (See the definition of the ICtCp colorspace for more
     * information.)
     *)
    ycc_to_rgb_matrix: array[0..8] of TAVRational; (* before PQ linearization *)
    ycc_to_rgb_offset: array[0..2] of TAVRational; (* input offset of neutral value *)
    rgb_to_lms_matrix: array[0..8] of TAVRational; (* after PQ linearization *)

    (**
     * Extra signal metadata (see Dolby patents for more info).
     *)
    signal_eotf: Word;
    signal_eotf_param0: Word;
    signal_eotf_param1: Word;
    signal_eotf_param2: Cardinal;
    signal_bit_depth: Byte;
    signal_color_space: Byte;
    signal_chroma_format: Byte;
    signal_full_range_flag: Byte; (* [0, 3] *)
    source_min_pq: Word;
    source_max_pq: Word;
    source_diagonal: Word;
  end;

(**
 * Combined struct representing a combination of header, mapping and color
 * metadata, for attaching to frames as side data.
 *
 * @note The struct must be allocated with av_dovi_metadata_alloc() and
 *       its size is not a part of the public ABI.
 *)
  PAVDOVIMetadata = ^TAVDOVIMetadata;
  TAVDOVIMetadata = record
    (**
     * Offset in bytes from the beginning of this structure at which the
     * respective structs start.
     *)
    header_offset: Size_t;   (* AVDOVIRpuDataHeader *)
    mapping_offset: Size_t;  (* AVDOVIDataMapping *)
    color_offset: Size_t;    (* AVDOVIColorMetadata *)
  end;

(**
 * Allocate an AVDOVIMetadata structure and initialize its
 * fields to default values.
 *
 * @param size If this parameter is non-NULL, the size in bytes of the
 *             allocated struct will be written here on success
 *
 * @return the newly allocated struct or NULL on failure
 *)
function av_dovi_metadata_alloc(size: PSize_t): PAVDOVIMetadata; cdecl; external AVUTIL_LIBNAME name _PU + 'av_dovi_metadata_alloc';

function av_dovi_get_header(const data: PAVDOVIMetadata): PAVDOVIRpuDataHeader; {$IFDEF USE_INLINE}inline;{$ENDIF}
function av_dovi_get_mapping(const data: PAVDOVIMetadata): PAVDOVIDataMapping; {$IFDEF USE_INLINE}inline;{$ENDIF}
function av_dovi_get_color(const data: PAVDOVIMetadata): PAVDOVIColorMetadata; {$IFDEF USE_INLINE}inline;{$ENDIF}

implementation

function av_dovi_get_header(const data: PAVDOVIMetadata): PAVDOVIRpuDataHeader;
var
  P: PByte;
begin
  P := PByte(data);
  Inc(P, data.header_offset);
  Result := PAVDOVIRpuDataHeader(P);
end;

function av_dovi_get_mapping(const data: PAVDOVIMetadata): PAVDOVIDataMapping;
var
  P: PByte;
begin
  P := PByte(data);
  Inc(P, data.mapping_offset);
  Result := PAVDOVIDataMapping(P);
end;

function av_dovi_get_color(const data: PAVDOVIMetadata): PAVDOVIColorMetadata;
var
  P: PByte;
begin
  P := PByte(data);
  Inc(P, data.color_offset);
  Result := PAVDOVIColorMetadata(P);
end;

end.
