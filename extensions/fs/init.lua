--- === hs.fs ===
---
--- Access/inspect the filesystem
---
--- Home: http://keplerproject.github.io/luafilesystem/
---
--- This module is produced by the Kepler Project under the name "Lua File System"

local module = require("hs.fs.internal")
module.volume = require("hs.fs.volume")
module.xattr  = require("hs.fs.xattr")

--- hs.fs.xattr.getHumanReadable(path, attribute, [options], [position]) -> string | true | nil
--- Function
--- A wrapper to [hs.fs.xattr.get](#get) which returns non UTF-8 data as a hexadecimal dump provided by `hs.utf8.hexDump`.
---
--- Parameters:
---  * see [hs.fs.xattr.get](#get)
---
--- Returns:
---  * if the returned data does not conform to proper UTF-8 byte sequences, passes the string through `hs.utf8.hexDump` first.  Otherwise the return values follow the description for [hs.fs.xattr.get](#get) .
---
--- Notes:
---  * This is provided for testing and debugging purposes; in general you probably want [hs.fs.xattr.get](#get) once you know how to properly understand the data returned for the attribute.
---  * This is similar to the long format option in the command line `xattr` command.
module.xattr.getHumanReadable = function(...)
    local val = module.xattr.get(...)
    if type(val) == "string" and val ~= hs.cleanUTF8forConsole(val) then
        val = require("hs.utf8").hexDump(val)
    end
    return val
end

--- hs.fs.volume.allVolumes([showHidden]) -> table
--- Function
--- Returns a table of information about disk volumes attached to the system
---
--- Parameters:
---  * showHidden - An optional boolean, true to show hidden volumes, false to not show hidden volumes. Defaults to false.
---
--- Returns:
---  * A table of information, where the keys are the paths of disk volumes
---
--- Notes:
---  * This is an alias for `hs.host.volumeInformation()`
---  * The possible keys in the table are:
---   * NSURLVolumeTotalCapacityKey - Size of the volume in bytes
---   * NSURLVolumeAvailableCapacityKey - Available space on the volume in bytes
---   * NSURLVolumeIsAutomountedKey - Boolean indicating if the volume was automounted
---   * NSURLVolumeIsBrowsableKey - Boolean indicating if the volume can be browsed
---   * NSURLVolumeIsEjectableKey - Boolean indicating if the volume can be ejected
---   * NSURLVolumeIsInternalKey - Boolean indicating if the volume is an internal drive or an external drive
---   * NSURLVolumeIsLocalKey - Boolean indicating if the volume is a local or remote drive
---   * NSURLVolumeIsReadOnlyKey - Boolean indicating if the volume is read only
---   * NSURLVolumeIsRemovableKey - Boolean indicating if the volume is removable
---   * NSURLVolumeMaximumFileSizeKey - Maximum file size the volume can support, in bytes
---   * NSURLVolumeUUIDStringKey - The UUID of volume's filesystem
---   * NSURLVolumeURLForRemountingKey - For remote volumes, the network URL of the volume
---   * NSURLVolumeLocalizedNameKey - Localized version of the volume's name
---   * NSURLVolumeNameKey - The volume's name
---   * NSURLVolumeLocalizedFormatDescriptionKey - Localized description of the volume
--- * Not all keys will be present for all volumes
local host = require("hs.host")
module.volume.allVolumes = host.volumeInformation

--- hs.fs.getFinderComments(path) -> string
--- Function
--- Get the Finder comments for the file or directory at the specified path
---
--- Parameters:
---  * path - the path to the file or directory you wish to get the comments of
---
--- Returns:
---  * a string containing the Finder comments for the file or directory specified.  If no comments have been set for the file, returns an empty string.  If an error occurs, most commonly an invalid path, this function will throw a Lua error.
---
--- Notes:
---  * This function uses `hs.osascript` to access the file comments through AppleScript
module.getFinderComments = function(path)
    local script = [[
tell application "Finder"
  set filePath to "]] .. tostring(path) .. [[" as posix file
  get comment of (filePath as alias)
end tell
]]
    local state, result, raw = require("hs.osascript").applescript(script)
    if state then
        return result
    else
        error(raw.NSLocalizedDescription, 2)
    end
end

--- hs.fs.setFinderComments(path, comment) -> boolean
--- Function
--- Set the Finder comments for the file or directory at the specified path to the comment specified
---
--- Parameters:
---  * path    - the path to the file or directory you wish to set the comments of
---  * comment - a string specifying the comment to set.  If this parameter is missing or is an explicit nil, the existing comment is cleared.
---
--- Returns:
---  * true on success; on error, most commonly an invalid path, this function will throw a Lua error.
---
--- Notes:
---  * This function uses `hs.osascript` to access the file comments through AppleScript
module.setFinderComments = function(path, comment)
    if comment == nil then comment = "" end
    local script = [[
tell application "Finder"
  set filePath to "]] .. tostring(path) .. [[" as posix file
  set comment of (filePath as alias) to "]] .. comment .. [["
end tell
]]
    local state, result, raw = require("hs.osascript").applescript(script)
    if state then
        return state
    else
        error(raw.NSLocalizedDescription, 2)
    end
end

return module
