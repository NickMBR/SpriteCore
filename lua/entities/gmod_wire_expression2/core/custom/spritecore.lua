--[[
	
	Sprite Core E2 Extension
	by NickMBR
	
	Release Date: 02/12/2016

]]--

-- HEADER --
E2Lib.RegisterExtension( "spritecore", false, "Create and Control Sprites with E2" )

-- CONVARS --
local wire_spritecore_max = CreateConVar( "wire_spritecore_max", "100", FCVAR_ARCHIVE )
local wire_spritecore_maxscale = CreateConVar( "wire_spritecore_maxscale", "16", FCVAR_ARCHIVE )

-- ARRAYS --
local SpriteTable = {}

local textures = {
	"sprites/light_glow03.vmt",
	"sprites/animglow01.vmt",
	"sprites/blueflare1.vmt",
	"sprites/blueglow1.vmt",
	"sprites/flare1.vmt",
	"sprites/glow01.spr",
	"sprites/glow02.vmt",
	"sprites/glow03.vmt",
	"sprites/glow04.vmt",
	"sprites/glow06.vmt",
	"sprites/glow07.vmt",
	"sprites/glow08.vmt",
	"sprites/halo01.vmt",
	"sprites/lamphalo.vmt",
	"sprites/light_ignorez.vmt",
	"sprites/light_glow01.vmt",
	"sprites/light_glow02.vmt",
	"sprites/light_glow03.vmt",
	"sprites/redglow2.vmt",
	"sprites/redglow4.vmt",
	"sprites/fire.vmt",
	"sprites/fire1.vmt",
	"sprites/fire2.vmt"
}

local rendermodes = {
	"0 = Normal",
	"1 = Color",
	"2 = Texture",
	"3 = Glow",
	"4 = Solid",
	"5 = Additive",
	"7 = Additive Fractional",
	"8 = Alpha Add",
	"9 = World Glow",
	"10 = Don't Render",
	"Default Render is 9 (World Glow)."
}

-- CHECK FUNCTIONS --
local function ValidateSprite( self, index )
	if SpriteTable[self.entity].count == wire_spritecore_max:GetInt() then
		return false
	end
	return true
end

local function checkSprite( self, index )
	if SpriteTable[self.entity].sprites[index] then
		return false
	end
	return true
end

local function getSprite( self, index )
	return SpriteTable[self.entity].sprites[index]
end

local function checkPath( path )

	local pathfix
	local str = string.find(path, ".vmt", 1)
	
	if str == nil then pathfix = path..".vmt" else pathfix = path end
	
	return pathfix
end

-- SPRITE CREATOR --
local function CreateSprite( self, Index, Path, Pos, Color, Alpha, Scale, Parent, RenderMode, Framerate)

	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, Index ) then return end

	-- Sets a default sprite in case fields are nil
	if not Pos then Pos = self.entity:GetPos() end
	if not Path then Path = "sprites/glow02.vmt" end
	if not RenderMode then RenderMode = 9 end
	if not Color then Color = Vector( 255, 255, 255 ) end
	if not Alpha then Alpha = 150 end
	if not Framerate then Framerate = 10 end
	if not Scale then Scale = 1 end
	if not Parent then Parent = self.entity end
	
	-- Sets a maximum sprite scale
	if Scale > wire_spritecore_maxscale:GetInt() then Scale = wire_spritecore_maxscale:GetInt() end
	
	-- Creates it
	local SPR = ents.Create( "env_sprite" )
	if not IsValid(SPR) then return end
	
	E2Lib.setPos(SPR, Pos)
	SPR:SetMoveType(MOVETYPE_NONE)
	
	SPR:SetSaveValue( "rendermode", RenderMode )
	SPR:SetSaveValue( "model", checkPath( Path ) )
	SPR:SetSaveValue( "rendercolor", string.format( "%i %i %i", Color.x, Color.y, Color.z ) )
	SPR:SetSaveValue( "framerate", Framerate )
	SPR:SetSaveValue( "scale", Scale )
	SPR:SetKeyValue( "renderamt", Alpha )
	
	-- updates the array
	SpriteTable[self.entity].sprites[Index] = SPR
	SpriteTable[self.entity].count = SpriteTable[self.entity].count + 1
	
	SPR:Spawn()
	SPR:Activate()
	SPR:SetParent( Parent )
	
	return SPR
end

-- SPRITE REMOVER --
local function spriteRemoveAll(self)
	for k, v in pairs (SpriteTable[self.entity].sprites) do
		if IsValid(v) then v:Remove() end
	end
	SpriteTable[self.entity].sprites = {}
	SpriteTable[self.entity].count = 0
end

-- E2 FUNCTIONS --
-- SPRITE CREATOR ALL --
-- Args: Index, Path, Pos, Color, Alpha, Scale, Parent, RenderMode, Framerate

__e2setcost(20)

-- SPRITE SPAWN FULL ARGS --
e2function entity spriteSpawn( index, string path, vector pos, vector color, alpha, scale, entity parent, rendermode, framerate )
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, index ) then return end
	if not checkSprite( self, index ) then return end
	
	pos = Vector(pos[1], pos[2], pos[3])
	color = Vector(color[1], color[2], color[3])
	
	return CreateSprite( self, index, path, pos, color, alpha, scale, parent, rendermode, framerate )
end

-- SPRITE SPAWN NO FRAMERATE --
e2function entity spriteSpawn( index, string path, vector pos, vector color, alpha, scale, entity parent, rendermode )
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, index ) then return end
	if not checkSprite( self, index ) then return end
	
	pos = Vector(pos[1], pos[2], pos[3])
	color = Vector(color[1], color[2], color[3])

	return CreateSprite( self, index, path, pos, color, alpha, scale, parent, rendermode )
end

-- SPRITE SPAWN NO RENDERMODE --
e2function entity spriteSpawn( index, string path, vector pos, vector color, alpha, scale, entity parent )
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, index ) then return end
	if not checkSprite( self, index ) then return end
	
	pos = Vector(pos[1], pos[2], pos[3])
	color = Vector(color[1], color[2], color[3])
	
	return CreateSprite( self, index, path, pos, color, alpha, scale, parent )
end

-- SPRITE SPAWN NO PARENT --
e2function entity spriteSpawn( index, string path, vector pos, vector color, alpha, scale )
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, index ) then return end
	if not checkSprite( self, index ) then return end
	
	pos = Vector(pos[1], pos[2], pos[3])
	color = Vector(color[1], color[2], color[3])
	
	return CreateSprite( self, index, path, pos, color, alpha, scale )
end

-- SPRITE SPAWN NO SCALE --
e2function entity spriteSpawn( index, string path, vector pos, vector color, alpha )
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, index ) then return end
	if not checkSprite( self, index ) then return end
	
	pos = Vector(pos[1], pos[2], pos[3])
	color = Vector(color[1], color[2], color[3])
	
	return CreateSprite( self, index, path, pos, color, alpha )
end

-- SPRITE SPAWN NO ALPHA --
e2function entity spriteSpawn( index, string path, vector pos, vector color )
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, index ) then return end
	if not checkSprite( self, index ) then return end
	
	pos = Vector(pos[1], pos[2], pos[3])
	color = Vector(color[1], color[2], color[3])
	
	return CreateSprite( self, index, path, pos, color )
end

-- SPRITE SPAWN NO COLOR --
e2function entity spriteSpawn( index, string path, vector pos )
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, index ) then return end
	if not checkSprite( self, index ) then return end
	
	pos = Vector(pos[1], pos[2], pos[3])
	color = Vector(color[1], color[2], color[3])
	
	return CreateSprite( self, index, path, pos )
end

-- SPRITE SPAWN NO POS --
e2function entity spriteSpawn( index, string path )
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, index ) then return end
	if not checkSprite( self, index ) then return end
	
	return CreateSprite( self, index, path )
end

-- SPRITE SPAWN ONLY INDEX --
e2function entity spriteSpawn( index )
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, index ) then return end
	if not checkSprite( self, index ) then return end
	
	return CreateSprite( self, index)
end

__e2setcost(10)

-- SPRITE TOGGLE --
e2function void spriteEnable( index, value )
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, index ) then return end
	
	local spr = getSprite(self, index)
	if IsValid( spr ) then spr:SetNoDraw( value ~= 1 ) end
end

-- SPRITE SET POS --
e2function void spriteSetPos( index, vector pos )
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, index ) then return end
	
	pos = Vector(pos[1], pos[2], pos[3])
	
	local spr = getSprite(self, index)
	if IsValid( spr ) then spr:SetPos( pos ) end
end

-- SPRITE SET COLOR --
e2function void spriteSetColor( index, vector color )
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, index ) then return end
	
	color = Vector(color[1], color[2], color[3])
	
	local spr = getSprite(self, index)
	if IsValid( spr ) then spr:SetKeyValue( "rendercolor", string.format( "%i %i %i", color.x, color.y, color.z ) ) end
end

-- SPRITE SET ALPHA --
e2function void spriteSetAlpha( index, alpha )
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, index ) then return end
	
	local spr = getSprite(self, index)
	if IsValid( spr ) then spr:SetKeyValue( "renderamt", alpha ) end
end

-- SPRITE SET SCALE --
e2function void spriteSetScale( index, scale )
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, index ) then return end
	
	local spr = getSprite(self, index)
	
	if scale > wire_spritecore_maxscale:GetInt() then scale = wire_spritecore_maxscale:GetInt() end
	if IsValid( spr ) then spr:SetKeyValue( "scale", scale ) end
end

-- SPRITE SET PARENT --
e2function void spriteSetParent( index, entity parent )
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, index ) then return end
	
	local spr = getSprite(self, index)
	if IsValid( spr ) and IsValid(parent) then spr:SetParent( parent ) end
end

-- SPRITE SET RENDERMODE --
e2function void spriteSetRendermode( index, rendermode )
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, index ) then return end
	
	local spr = getSprite(self, index)
	if IsValid( spr ) then spr:SetKeyValue( "rendermode", rendermode ) end
end

-- SPRITE SET FRAMERATE --
e2function void spriteSetFramerate( index, framerate )
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not ValidateSprite( self, index ) then return end
	
	local spr = getSprite(self, index)
	if IsValid( spr ) then spr:SetKeyValue( "framerate", framerate ) end
end

-- PRINT AVALIABLE SPRITE LIST --
e2function void spriteList()
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not textures then return end
	
	self.player:ChatPrint("Sprite List:")
	for k, v in pairs (textures) do
		self.player:ChatPrint(v)
	end
	
	self.player:ChatPrint("[SpriteCore] Open the chat to see the texture list above.")
end

-- PRINT RENDER MODES LIST --
e2function void spriteRList()
	if not self.player:IsValid() or not self.player:IsPlayer() then return end
	if not textures then return end
	
	self.player:ChatPrint("Render Modes:")
	for k, v in pairs (rendermodes) do
		self.player:ChatPrint(v)
	end
	
	self.player:ChatPrint("[SpriteCore] Open the chat to see the render modes list above.")
end

-- CALLBACKS --
registerCallback("construct", function(self)
	SpriteTable[self.entity] = {
		sprites = {},
		count = 0
	}
end)

registerCallback("destruct", function(self)
	spriteRemoveAll(self)
end)