//
//  ========================================================================
//  Copyright (c) 1995-2017 Mort Bay Consulting Pty. Ltd.
//  ------------------------------------------------------------------------
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Eclipse Public License v1.0
//  and Apache License v2.0 which accompanies this distribution.
//
//      The Eclipse Public License is available at
//      http://www.eclipse.org/legal/epl-v10.html
//
//      The Apache License v2.0 is available at
//      http://www.opensource.org/licenses/apache2.0.php
//
//  You may elect to redistribute this code under either of these licenses.
//  ========================================================================
//

package org.eclipset.jetty.server;

import org.eclipse.jetty.http.HttpCompliance;
import org.eclipse.jetty.http.HttpVersion;
import org.eclipse.jetty.io.Connection;
import org.eclipse.jetty.io.EndPoint;
import org.eclipse.jetty.server.*;
import org.eclipse.jetty.server.Connector;
import org.eclipse.jetty.server.HttpConfiguration;
import org.eclipse.jetty.server.HttpConnection;
import org.eclipse.jetty.util.annotation.Name;

/** A Connection Factory for HTTP Connections.
 * <p>Accepts connections either directly or via SSL and/or ALPN chained connection factories.  The accepted
 * {@link org.eclipse.jetty.server.HttpConnection}s are configured by a {@link org.eclipse.jetty.server.HttpConfiguration} instance that is either created by
 * default or passed in to the constructor.
 */
public class HttpConnectionFactory extends org.eclipse.jetty.server.AbstractConnectionFactory implements org.eclipse.jetty.server.HttpConfiguration.ConnectionFactory
{
    private final org.eclipse.jetty.server.HttpConfiguration _config;
    private HttpCompliance _httpCompliance;
    private boolean _recordHttpComplianceViolations = false;

    public HttpConnectionFactory()
    {
        this(new org.eclipse.jetty.server.HttpConfiguration());
    }
    
    public HttpConnectionFactory(@Name("config") org.eclipse.jetty.server.HttpConfiguration config)
    {
        this(config,null);
    }

    public HttpConnectionFactory(@Name("config") org.eclipse.jetty.server.HttpConfiguration config, @Name("compliance") HttpCompliance compliance)
    {
        super(HttpVersion.HTTP_1_1.asString());
        _config=config;
        _httpCompliance=compliance==null?HttpCompliance.RFC7230:compliance;
        if (config==null)
            throw new IllegalArgumentException("Null HttpConfiguration");
        addBean(_config);
    }

    @Override
    public HttpConfiguration getHttpConfiguration()
    {
        return _config;
    }

    public HttpCompliance getHttpCompliance()
    {
        return _httpCompliance;
    }

    public boolean isRecordHttpComplianceViolations()
    {
        return _recordHttpComplianceViolations;
    }

    /**
     * @param httpCompliance String value of {@link HttpCompliance}
     */
    public void setHttpCompliance(HttpCompliance httpCompliance)
    {
        _httpCompliance = httpCompliance;
    }

    @Override
    public Connection newConnection(Connector connector, EndPoint endPoint)
    {
        org.eclipse.jetty.server.HttpConnection conn = new HttpConnection(_config, connector, endPoint, _httpCompliance,isRecordHttpComplianceViolations());
        return configure(conn, connector, endPoint);
    }
    
    
    public void setRecordHttpComplianceViolations(boolean recordHttpComplianceViolations)
    {
        this._recordHttpComplianceViolations = recordHttpComplianceViolations;
    }
}
