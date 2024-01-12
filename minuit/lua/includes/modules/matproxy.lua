module( "matproxy", package.seeall )
local pairs = pairs
ProxyList = {}
ActiveList = {}

--
-- Called by engine, returns true if we're overriding a proxy
--
function ShouldOverrideProxy( name )
	return ProxyList[ name ] ~= nil
end

--
-- Called to add a new proxy (see lua/matproxy/ for examples)
--
function Add(tbl)
	if tbl.name and tbl.bind then
		local bReloading = (ProxyList[tbl.name] ~= nil)
		ProxyList[tbl.name] = tbl
		if bReloading then
			local active_list = ActiveList
			for k, v in pairs(active_list) do
				if tbl.name == v.name then
					Msg("Reloading: ", v.Material, "\n")
					Init(tbl.name, k, v.Material, v.Values)
				end
			end
		end
	end
end

--
-- Called by the engine from OnBind
--
function Call(name, mat, ent)
	local proxy = ActiveList[name]
	if proxy then
		local bind = proxy.bind
		if bind then
			bind(proxy, mat, ent)
		end
	end
end

function Init(name, uname, mat, values)
	local proxy = ProxyList[name]
	if proxy then
		ActiveList[uname] = table.Copy(proxy)
		local proxy = ActiveList[uname]
		local init = proxy.init
		if init then
			init(proxy, mat, values)
			proxy.Values = values
			proxy.Material = mat
		end
	end
end