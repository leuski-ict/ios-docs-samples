#if !defined(GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO) || !GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO
#import "CloudTts.pbobjc.h"
#endif

#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import <ProtoRPC/ProtoService.h>
#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>
#endif

@class ListVoicesRequest;
@class ListVoicesResponse;
@class SynthesizeSpeechRequest;
@class SynthesizeSpeechResponse;

#if !defined(GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO) || !GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO
  #import <googleapis/Annotations.pbobjc.h>
#endif

@class GRPCProtoCall;
@class GRPCUnaryProtoCall;
@class GRPCStreamingProtoCall;
@class GRPCCallOptions;
@protocol GRPCProtoResponseHandler;


NS_ASSUME_NONNULL_BEGIN

@protocol TextToSpeech2 <NSObject>

#pragma mark ListVoices(ListVoicesRequest) returns (ListVoicesResponse)

/**
 * Returns a list of [Voice][google.cloud.texttospeech.v1beta1.Voice]
 * supported for synthesis.
 */
- (GRPCUnaryProtoCall *)listVoicesWithMessage:(ListVoicesRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

#pragma mark SynthesizeSpeech(SynthesizeSpeechRequest) returns (SynthesizeSpeechResponse)

/**
 * Synthesizes speech synchronously: receive results after all text input
 * has been processed.
 */
- (GRPCUnaryProtoCall *)synthesizeSpeechWithMessage:(SynthesizeSpeechRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions;

@end

@protocol TextToSpeech <NSObject>

#pragma mark ListVoices(ListVoicesRequest) returns (ListVoicesResponse)

/**
 * Returns a list of [Voice][google.cloud.texttospeech.v1beta1.Voice]
 * supported for synthesis.
 */
- (void)listVoicesWithRequest:(ListVoicesRequest *)request handler:(void(^)(ListVoicesResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * Returns a list of [Voice][google.cloud.texttospeech.v1beta1.Voice]
 * supported for synthesis.
 */
- (GRPCProtoCall *)RPCToListVoicesWithRequest:(ListVoicesRequest *)request handler:(void(^)(ListVoicesResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark SynthesizeSpeech(SynthesizeSpeechRequest) returns (SynthesizeSpeechResponse)

/**
 * Synthesizes speech synchronously: receive results after all text input
 * has been processed.
 */
- (void)synthesizeSpeechWithRequest:(SynthesizeSpeechRequest *)request handler:(void(^)(SynthesizeSpeechResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * Synthesizes speech synchronously: receive results after all text input
 * has been processed.
 */
- (GRPCProtoCall *)RPCToSynthesizeSpeechWithRequest:(SynthesizeSpeechRequest *)request handler:(void(^)(SynthesizeSpeechResponse *_Nullable response, NSError *_Nullable error))handler;


@end


#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
/**
 * Basic service implementation, over gRPC, that only does
 * marshalling and parsing.
 */
@interface TextToSpeech : GRPCProtoService<TextToSpeech, TextToSpeech2>
- (instancetype)initWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithHost:(NSString *)host;
+ (instancetype)serviceWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
#endif

NS_ASSUME_NONNULL_END

