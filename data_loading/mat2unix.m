function unixTime = mat2unix(matTime)

unixTime = int32(floor(86400 * (matTime - datenum('01-Jan-1970'))));

end