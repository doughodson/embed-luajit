
--
-- If premake command is not supplied an action (target compiler), exit!
--
-- Targets of interest:
--     vs2019     (Visual Studio 2019)
--     gmake      (Linux make)
--
if (_ACTION == nil) then
    return
end

Lua_Root     = "../../LuaJIT-2.0.5/"
Lua_SrcPath  = Lua_Root .. "src/"
Lua_LibPath  = Lua_Root .. "lib/"

workspace "embed-luajit"

   -- destination directory for generated solution/project files
   location ("../" .. _ACTION)

   -- don't automatically prefix the name of generated targets
   targetprefix ""

   -- compile for 64 bits (no 32 bits for now)
   architecture "x86_64"

   --
   -- Build (solution) configuration options:
   --     Release        (Runtime library is Multi-threaded DLL)
   --     Debug          (Runtime library is Multi-threaded Debug DLL)
   --
   configurations { "Release", "Debug" }

   -- common release configuration flags and symbols
   filter "configurations:Release"
      optimize "On"

   filter "system:windows"
         -- favor speed over size
         buildoptions { "/Ot" }
         defines { "WIN32", "_LIB", "NDEBUG" }

   -- common debug configuration flags and symbols
   filter "configurations:Debug"
      symbols "On"

   filter "system:windows"
         defines { "WIN32", "_LIB", "_DEBUG" }

   --
   -- stock lua library, interpreter and compiler
   --

   -- LuaJIT library (compiled as a shared library)
   project "LuaJIT"
      targetname "lua"
      kind "SharedLib"
      language "C"
      targetdir ( Lua_LibPath )
      includedirs { Lua_SrcPath }
      files {
         Lua_SrcPath .. "**.*"    -- include all source files
      }
      excludes {
         Lua_SrcPath .. "luajit.c"
      }
      if os.ishost("windows") then
         defines { "LUA_BUILD_AS_DLL" }
      end
      if os.ishost("linux") then
         defines { "LUA_USE_LINUX" }
      end

   -- LuaJIT interpreter (repl), uses shared library / dll
   project "repl"
      targetname "lua"
      targetdir ("../../repl")
      kind "ConsoleApp"
      language "C"
      includedirs { Lua_SrcPath }
      libdirs     { Lua_LibPath }
      files {
         Lua_SrcPath .. "luajit.c"
      }
      links {"lua"}
      if os.ishost("linux") then
         links {"dl", "m"}
      end

