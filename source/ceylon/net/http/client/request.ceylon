import ceylon.io {
    SocketAddress,
    FileDescriptor,
    Socket
}
import ceylon.net.http {
    Message,
    Method,
    getMethod=get
}
import ceylon.net.uri {
    Uri
}

FileDescriptor send(SocketAddress|FileDescriptor target, Message request) {
    switch (target)
    case (is FileDescriptor) {
        
        return target;
    }
    case (is SocketAddress) {
        Socket socket = nothing;
        
        return socket;
    }
}

Message receive(FileDescriptor incoming) {
    return nothing;
}

Message request(Method method, Uri uri) {
    assert (exists String scheme = uri.scheme, scheme in ["http", "https"]);
    assert (exists String host = uri.authority.host);
    
    Integer port;
    if (exists p = uri.authority.port) {
        port = p;
    } else if (scheme == "http") {
        port = 80;
    } else { // if (scheme == "https")
        port = 443;
        // TODO "secure" Boolean?
    }
    
    value socketAddress = SocketAddress(host, port);
    
    value request = Message(nothing);
    
    FileDescriptor incoming = send(socketAddress, request);
    return receive(incoming);
}

Message get(Uri uri) {
    return request(getMethod, uri);
}

{Message+} getFollowingRedirects(Uri uri) {
    //return request(getMethod, uri);
    return nothing; // TODO
}
