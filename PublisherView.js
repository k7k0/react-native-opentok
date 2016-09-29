/**
 * Copyright (c) 2015-present, Callstack Sp z o.o.
 * All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import { requireNativeComponent, View, NativeModules } from 'react-native';
import React from 'react';
import SessionViewProps from './SessionViewProps';
import withLoadingSpinner from './withLoadingSpinner';

const OpenTokPublisherViewManager = NativeModules.OpenTokPublisherViewManager;

const noop = () => {};

/**
 * A React component for publishing video stream over OpenTok to the
 * session provided
 *
 * `Publisher` supports default styling, just like any other View.
 *
 * After successfull session creation, the publisher view displaying live
 * preview of a stream will be appended to the container and will take available
 * space, as layed out by React.
 */
class PublisherView extends React.Component {
  static propTypes = {
    ...View.propTypes,
    ...SessionViewProps,
    /**
     * This function is called on publish start
     */
    onPublishStart: React.PropTypes.func,
    /**
     * This function is called on publish error
     */
    onPublishError: React.PropTypes.func,
    /**
     * This function is called on publish stop
     */
    onPublishStop: React.PropTypes.func,
    /**
     * This function is called when new client is connected to
     * the current stream
     *
     * Receives payload:
     * ```
     * {
     *   connectionId: string,
     *   creationTime: string,
     *   data: string,
     * }
     * ```
     */
    onClientConnected: React.PropTypes.func,
    /**
     * This function is called when client is disconnected from
     * the current stream
     *
     * Receives payload:
     * ```
     * {
     *   connectionId: string,
     * }
     * ```
     */
    onClientDisconnected: React.PropTypes.func,

    /**
     * This function is called when the connection is made to the server
     * Not much use, mainly can be used as part of debugging process.
     * Publishing will be initiated right away
     *
     * Receives payload:
     * ```
     * {
     *   sessionId: string,
     * }
     * ```
     */
    onSessionDidConnect: React.PropTypes.func,
    /**
     * This function is called when we get disconnected from the session.
     *
     * Receives payload:
     * ```
     * {
     *   sessionId: string,
     * }
     * ```
     */
    onSessionDidDisconnect: React.PropTypes.func,
    /**
     * This function is called when the session is being recorded
     *
     * Receives payload:
     * ```
     * {
     *   archiveId: string,
     *   name: string,
     * }
     * ```
     */
    onArchiveStarted: React.PropTypes.func,
    /**
     * This function is called when the session recording finishes
     *
     * Receives payload:
     * ```
     * {
     *   archiveId: string,
     * }
     * ```
     */
    onArchiveStopped: React.PropTypes.func,
};


  static defaultProps = {
    onPublishStart: noop,
    onPublishError: noop,
    onPublishStop: noop,
    onClientConnected: noop,
    onClientDisconnected: noop,
    onSessionDidConnect: noop,
    onSessionDidDisconnect: noop,
    onArchiveStarted: noop,
    onArchiveStopped: noop,
  };

  pausePublish() {
    OpenTokPublisherViewManager.pausePublish();
  }
  resumePublish() {
    OpenTokPublisherViewManager.resumePublish();
  }

  render() {
    return <RCTPublisherView {...this.props} />;
  }
}

const RCTPublisherView = requireNativeComponent('RCTOpenTokPublisherView', PublisherView);
export default withLoadingSpinner(PublisherView, 'onPublishStart');
