import 'package:dio/dio.dart';
import 'package:easy_onvif/model/envelope.dart';
import 'package:easy_onvif/model/ptzPosition.dart';
import 'package:xml/xml.dart';

import '../onvif.dart';

///Utility class for interacting through the SOAP protocol
class Soap {
  ///Send the SOAP [requestData] to the given [url] endpoint.
  static Future<String> send(String url, String requestData) async {
    final dio = Dio();

    Response response;

    try {
      response = await dio.post(url,
          data: requestData,
          options: Options(headers: {
            Headers.contentTypeHeader: 'text/xml; charset=utf-8',
            Headers.contentLengthHeader: requestData.length
          }));
    } on DioError catch (error) {
      if (error.response?.statusCode == 500) {
        final jsonMap = OnvifUtil.xmlToMap(error.response?.data);

        final envelope = Envelope.fromJson(jsonMap);

        if (envelope.body.hasFault) {
          throw Exception(envelope.body.fault!.reason.why);
        }
      }

      throw Exception(error.toString());
    }

    return response.data;
  }

  ///Retrieve an onvif SOAP envelope
  static Future<Envelope> retrieveEnvlope(String uri, XmlDocument soapRequest,
      {Function? postProcess}) async {
    final soapResponse = await Soap.send(uri, soapRequest.toString());

    final jsonMap = OnvifUtil.xmlToMap(soapResponse);

    final envelope = Envelope.fromJson(jsonMap);

    if (postProcess != null) {
      postProcess(soapResponse, jsonMap, envelope);
    }

    return envelope;
  }
}

///Helper methods for building the [SoapRequest]
class SoapRequest {
  static final builder = XmlBuilder();

  ///XML for the SOAP envelope
  static XmlDocument envelope(
      XmlDocumentFragment? header, XmlDocumentFragment body) {
    builder.declaration(encoding: 'UTF-8');

    builder.element('Envelope', nest: () {
      builder.namespace('http://www.w3.org/2003/05/soap-envelope', 's');

      builder.element('Header',
          namespace: 'http://www.w3.org/2003/05/soap-envelope', nest: header);

      builder.element('Body',
          namespace: 'http://www.w3.org/2003/05/soap-envelope',
          namespaces: {
            'http://www.w3.org/2001/XMLSchema-instance': 'xsi',
            'http://www.w3.org/2001/XMLSchema': 'xsd'
          },
          nest: body);
    });

    return builder.buildDocument();
  }

  ///XML for the SOAP security header
  static XmlDocumentFragment header(XmlDocumentFragment security) => security;

  ///XML for the SOAP [security]
  static XmlDocumentFragment security(
      {required String username,
      required String password,
      required String nonce,
      required String created}) {
    builder.element('Security', nest: () {
      builder.namespace('http://www.w3.org/2003/05/soap-envelope', 's');
      builder.namespace(
          'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd');
      builder.attribute('mustUnderstand', 1,
          namespace: 'http://www.w3.org/2003/05/soap-envelope');
      builder.element('UsernameToken', nest: () {
        builder.element('Username', nest: username);
        builder.element('Password',
            attributes: {
              'Type':
                  'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest'
            },
            nest: password);
        builder.element('Nonce',
            attributes: {
              'EncodingType':
                  'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary'
            },
            nest: nonce);
        builder.element('Created', nest: () {
          builder.namespace(
              'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd');
          builder.text(created);
        });
      });
    });

    return builder.buildFragment();
  }

  ///XML for the [systemDateAndTime]
  static XmlDocumentFragment systemDateAndTime() {
    builder.element('GetSystemDateAndTime', nest: () {
      builder.namespace('http://www.onvif.org/ver10/device/wsdl');
    });

    return builder.buildFragment();
  }

  ///XML for the [capabilities]
  static XmlDocumentFragment capabilities(String category) {
    builder.element('GetCapabilities', nest: () {
      builder.namespace('http://www.onvif.org/ver10/device/wsdl');
      builder.element('Cagtegory', nest: () {
        builder.text(category);
      });
    });

    return builder.buildFragment();
  }

  ///XML for the [videoSources]
  static XmlDocumentFragment videoSources() {
    builder.element('GetVideoSources', nest: () {
      builder.namespace('http://www.onvif.org/ver10/device/wsdl');
    });

    return builder.buildFragment();
  }

  ///XML for the [profiles]
  static XmlDocumentFragment profiles() {
    builder.element('GetProfiles', nest: () {
      builder.namespace('http://www.onvif.org/ver10/device/wsdl');
    });

    return builder.buildFragment();
  }

  ///XML for the [presets], requires a [profileToken]
  static XmlDocumentFragment presets(String profileToken) {
    builder.element('GetPresets', nest: () {
      builder.namespace('http://www.onvif.org/ver10/device/wsdl');
      builder.element('ProfileToken', nest: () {
        builder.text(profileToken);
      });
    });

    return builder.buildFragment();
  }

  ///XML for the [deviceInformation]
  static XmlDocumentFragment deviceInformation() {
    builder.element('GetDeviceInformation', nest: () {
      builder.namespace('http://www.onvif.org/ver10/device/wsdl');
    });

    return builder.buildFragment();
  }

  ///XML for the [endpointReference]
  static XmlDocumentFragment endpointReference() {
    builder.element('GetEndpointReference', nest: () {
      builder.namespace('http://www.onvif.org/ver10/device/wsdl');
    });

    return builder.buildFragment();
  }

  ///XML for the [status], requires a [profileToken]
  static XmlDocumentFragment status(String profileToken) {
    builder.element('GetStatus', nest: () {
      builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
      builder.element('ProfileToken', nest: () {
        builder.text(profileToken);
      });
    });

    return builder.buildFragment();
  }

  ///XML for the [streamUri], requires a [profileToken]
  static XmlDocumentFragment streamUri(String profileToken,
      {String streamType: 'RTP-Unicast', String transportProtocol: 'RTSP'}) {
    builder.element('GetStreamUri', nest: () {
      builder.namespace('http://www.onvif.org/ver10/device/wsdl');
      builder.element('StreamSetup', nest: () {
        builder.element('Stream', nest: () {
          builder.namespace('http://www.onvif.org/ver10/schema');
          builder.text(streamType);
        });
        builder.element('Transport', nest: () {
          builder.namespace('http://www.onvif.org/ver10/schema');
          builder.element('Protocol', nest: () {
            builder.text(transportProtocol);
          });
        });
      });
      builder.element('ProfileToken', nest: () {
        builder.text(profileToken);
      });
    });

    return builder.buildFragment();
  }

  ///XML for the [snapshotUri], requires a [profileToken]
  static XmlDocumentFragment snapshotUri(String profileToken) {
    builder.element('GetSnapshotUri', nest: () {
      builder.namespace('http://www.onvif.org/ver10/device/wsdl');
      builder.element('ProfileToken', nest: () {
        builder.text(profileToken);
      });
    });

    return builder.buildFragment();
  }

  ///XML for the [services]
  static XmlDocumentFragment services() {
    builder.element('GetServices', nest: () {
      builder.namespace('http://www.onvif.org/ver10/device/wsdl');
      builder.element('IncludeCapability', nest: () {
        builder.text('false');
      });
    });

    return builder.buildFragment();
  }

  ///XML for the [snapshotUri], requires a [profileToken] and [Preset]
  static XmlDocumentFragment gotoPreset(String profileToken, Preset preset) {
    builder.element('GotoPreset', nest: () {
      builder.namespace('http://www.onvif.org/ver10/device/wsdl');
      builder.element('ProfileToken', nest: () {
        builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
        builder.text(profileToken);
      });
      builder.element('PresetToken', nest: () {
        builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
        builder.text(preset.token);
      });
      builder.element('Speed', nest: () {
        if (preset.position.panTilt != null) {
          builder.element('PanTilt', nest: () {
            builder.namespace('http://www.onvif.org/ver10/schema');
            builder.attribute('x', preset.position.panTilt!.x);
            builder.attribute('y', preset.position.panTilt!.y);
          });
        }
        if (preset.position.zoom != null) {
          builder.element('Zoom', nest: () {
            builder.namespace('http://www.onvif.org/ver10/schema');
            builder.attribute('x', preset.position.zoom!.x);
          });
        }
      });
    });

    return builder.buildFragment();
  }

  static XmlDocumentFragment networkProtocols() {
    builder.element('GetNetworkProtocols', nest: () {
      builder.namespace('http://www.onvif.org/ver10/device/wsdl');
    });

    return builder.buildFragment();
  }

  static XmlDocumentFragment createUsers(List<User> users) {
    builder.element('CreateUsers', nest: () {
      builder.namespace('http://www.onvif.org/ver10/device/wsdl');
      users.forEach((user) => builder.element('User', nest: () {
            builder.namespace('http://www.onvif.org/ver10/device/wsdl');
            builder.element('Username', nest: () {
              builder.namespace('http://www.onvif.org/ver10/schema');
              builder.text(user.username);
            });
            builder.element('Password', nest: () {
              builder.namespace('http://www.onvif.org/ver10/schema');
              builder.text(user.password);
            });
            builder.element('UserLevel', nest: () {
              builder.namespace('http://www.onvif.org/ver10/schema');
              builder.text(user.userLevel);
            });
          }));
    });

    return builder.buildFragment();
  }

  static XmlDocumentFragment hostname() {
    builder.element('GetHostname', nest: () {
      builder.namespace('http://www.onvif.org/ver10/device/wsdl');
    });

    return builder.buildFragment();
  }

  static XmlDocumentFragment ntp() {
    builder.element('GetNTP', nest: () {
      builder.namespace('http://www.onvif.org/ver10/device/wsdl');
    });

    return builder.buildFragment();
  }

  static XmlDocumentFragment systemUris() {
    builder.element('GetSystemUris', nest: () {
      builder.namespace('http://www.onvif.org/ver10/device/wsdl');
    });

    return builder.buildFragment();
  }

  static XmlDocumentFragment users() {
    builder.element('GetUsers', nest: () {
      builder.namespace('http://www.onvif.org/ver10/device/wsdl');
    });

    return builder.buildFragment();
  }

  static XmlDocumentFragment absoluteMove(
      String profileToken, PtzPosition place, PtzPosition? speed) {
    builder.element('AbsoluteMove', nest: () {
      builder.namespace('http://www.onvif.org/ver20/ptz/wsdl'); //tptz
      builder.element('ProfileToken', nest: () {
        builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
        builder.text(profileToken);
      });
      builder.element('Position', nest: () {
        builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
        builder.element('PanTilt', nest: () {
          builder.namespace('http://www.onvif.org/ver10/schema');
          builder.attribute('x', place.panTilt!.x);
          builder.attribute('y', place.panTilt!.y);
        });
        builder.element('Zoom', nest: () {
          builder.namespace('http://www.onvif.org/ver10/schema');
          builder.attribute('x', place.zoom!.x);
        });
      });
      if (speed != null) {
        builder.element('Speed', nest: () {
          builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
          if (speed.panTilt != null) {
            builder.element('PanTilt', nest: () {
              builder.namespace('http://www.onvif.org/ver10/schema');
              builder.attribute('x', speed.panTilt!.x);
              builder.attribute('y', speed.panTilt!.y);
            });
          }
          if (speed.zoom != null) {
            builder.element('Zoom', nest: () {
              builder.namespace('http://www.onvif.org/ver10/schema');
              builder.attribute('x', speed.zoom!.x);
            });
          }
        });
      }
    });

    return builder.buildFragment();
  }

  static XmlDocumentFragment relativeMove(
      String profileToken, PtzPosition move) {
    builder.element('RelativeMove', nest: () {
      builder.namespace('http://www.onvif.org/ver20/ptz/wsdl'); //tptz
      builder.element('ProfileToken', nest: () {
        builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
        builder.text(profileToken);
      });
      builder.element('Translation', nest: () {
        builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
        if (move.panTilt != null) {
          builder.element('PanTilt', nest: () {
            builder.namespace('http://www.onvif.org/ver10/schema');
            builder.attribute('x', move.panTilt!.x);
            builder.attribute('y', move.panTilt!.y);
          });
        }
        if (move.zoom != null) {
          builder.element('Zoom', nest: () {
            builder.namespace('http://www.onvif.org/ver10/schema');
            builder.attribute('x', move.zoom!.x);
          });
        }
      });
    });

    return builder.buildFragment();
  }

  static XmlDocumentFragment removePreset(String profileToken, Preset preset) {
    builder.element('RemovePreset', nest: () {
      builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
      builder.element('ProfileToken', nest: () {
        builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
        builder.text(profileToken);
      });
      builder.element('PresetToken', nest: () {
        builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
        builder.text(preset.token);
      });
    });

    return builder.buildFragment();
  }

  static XmlDocumentFragment setPreset(String profileToken, Preset preset) {
    builder.element('SetPreset', nest: () {
      builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
      builder.element('ProfileToken', nest: () {
        builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
        builder.text(profileToken);
      });
      if (preset.name != '') {
        builder.element('PresetName', nest: () {
          builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
          builder.text(preset.name);
        });
      }
      if (preset.token != '') {
        builder.element('PresetToken', nest: () {
          builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
          builder.text(preset.token);
        });
      }
    });

    return builder.buildFragment();
  }

  static XmlDocumentFragment stop(String profileToken,
      {bool panTilt = false, bool zoom = false}) {
    builder.element('Stop', nest: () {
      builder.namespace('http://www.onvif.org/ver20/ptz/wsdl'); //tptz
      builder.element('ProfileToken', nest: () {
        builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
        builder.text(profileToken);
      });

      builder.element('PanTilt', nest: () {
        builder.namespace('http://www.onvif.org/ver10/schema');
        builder.text('$panTilt');
      });

      builder.element('Zoom', nest: () {
        builder.namespace('http://www.onvif.org/ver10/schema');
        builder.text('$zoom');
      });
    });

    return builder.buildFragment();
  }

  static XmlDocumentFragment continuousMove(
      String profileToken, PtzPosition velocity, int? timeout) {
    builder.element('ContinuousMove', nest: () {
      builder.namespace('http://www.onvif.org/ver20/ptz/wsdl'); //tptz
      builder.element('ProfileToken', nest: () {
        builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
        builder.text(profileToken);
      });
      builder.element('Velocity', nest: () {
        builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');

        builder.element('PanTilt', nest: () {
          builder.namespace('http://www.onvif.org/ver10/schema');
          builder.attribute('x', velocity.panTilt!.x);
          builder.attribute('y', velocity.panTilt!.y);
        });
        builder.element('Zoom', nest: () {
          builder.namespace('http://www.onvif.org/ver10/schema');
          builder.attribute('x', velocity.zoom!.x);
        });
      });
      builder.element('Timeout', nest: () {
        builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
        builder.text('PT${timeout}S');
      });
    });

    return builder.buildFragment();
  }

  static XmlDocumentFragment getPtzConfigurations() {
    builder.element('GetConfigurations', nest: () {
      builder.namespace('http://www.onvif.org/ver20/ptz/wsdl');
    });

    return builder.buildFragment();
  }

  static XmlDocumentFragment audioSources() {
    builder.element('GetAudioSources', nest: () {
      builder.namespace('http://www.onvif.org/ver10/media/wsdl');
    });

    return builder.buildFragment();
  }

  static XmlDocumentFragment startMulticastStreaming() {
    builder.element('StartMulticastStreaming', nest: () {
      builder.namespace('http://www.onvif.org/ver10/media/wsdl');
    });

    return builder.buildFragment();
  }

  static XmlDocumentFragment stopMulticastStreaming() {
    builder.element('StopMulticastStreaming', nest: () {
      builder.namespace('http://www.onvif.org/ver10/media/wsdl');
    });

    return builder.buildFragment();
  }
}
