local function getTransparency(activated: boolean, setInvisible: boolean, setTransparency: number?)
	return if activated then setTransparency or 0 else setInvisible and 1 or 0.6
end

return getTransparency
