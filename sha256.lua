local bit32 = bit32

local function hex_to_num(hex)
	return tonumber(hex,16)
end

local initial_hash_hex = {"6a09e667","bb67ae85","3c6ef372","a54ff53a","510e527f","9b05688c","1f83d9ab","5be0cd19"}
local initial_hash = {}
for i,v in ipairs(initial_hash_hex) do
	initial_hash[i] = hex_to_num(v)
end

local k_hex = {
	"428a2f98","71374491","b5c0fbcf","e9b5dba5","3956c25b","59f111f1","923f82a4","ab1c5ed5",
	"d807aa98","12835b01","243185be","550c7dc3","72be5d74","80deb1fe","9bdc06a7","c19bf174",
	"e49b69c1","efbe4786","0fc19dc6","240ca1cc","2de92c6f","4a7484aa","5cb0a9dc","76f988da",
	"983e5152","a831c66d","b00327c8","bf597fc7","c6e00bf3","d5a79147","06ca6351","14292967",
	"27b70a85","2e1b2138","4d2c6dfc","53380d13","650a7354","766a0abb","81c2c92e","92722c85",
	"a2bfe8a1","a81a664b","c24b8b70","c76c51a3","d192e819","d6990624","f40e3585","106aa070",
	"19a4c116","1e376c08","2748774c","34b0bcb5","391c0cb3","4ed8aa4a","5b9cca4f","682e6ff3",
	"748f82ee","78a5636f","84c87814","8cc70208","90befffa","a4506ceb","bef9a3f7","c67178f2"
}
local k = {}
for i,v in ipairs(k_hex) do
	k[i] = hex_to_num(v)
end

local function right_rotate(x,n)
	return bit32.bor(bit32.rshift(x,n), bit32.lshift(x,32-n))
end

local function sha256(message)
	local message_bytes = {string.byte(message,1,#message)}
	local bit_len_high = 0
	local bit_len_low = #message_bytes * 8
	table.insert(message_bytes,128)
	while (#message_bytes % 64) ~= 56 do
		table.insert(message_bytes,0)
	end
	for i=3,0,-1 do
		table.insert(message_bytes, bit32.band(bit32.rshift(bit_len_high, i*8),255))
	end
	for i=3,0,-1 do
		table.insert(message_bytes, bit32.band(bit32.rshift(bit_len_low, i*8),255))
	end
	local h = {table.unpack(initial_hash)}
	for chunk=1,#message_bytes,64 do
		local w = {}
		for i=0,15 do
			local j = chunk + i*4
			w[i] = bit32.bor(
				bit32.lshift(message_bytes[j],24),
				bit32.lshift(message_bytes[j+1],16),
				bit32.lshift(message_bytes[j+2],8),
				message_bytes[j+3]
			)
		end
		for i=16,63 do
			local s0 = bit32.bxor(right_rotate(w[i-15],7), right_rotate(w[i-15],18), bit32.rshift(w[i-15],3))
			local s1 = bit32.bxor(right_rotate(w[i-2],17), right_rotate(w[i-2],19), bit32.rshift(w[i-2],10))
			w[i] = bit32.band(w[i-16] + s0 + w[i-7] + s1, 4294967295)
		end
		local a,b,c,d,e,f,g,h0 = table.unpack(h)
		for i=0,63 do
			local s1 = bit32.bxor(right_rotate(e,6), right_rotate(e,11), right_rotate(e,25))
			local ch = bit32.bxor(bit32.band(e,f), bit32.band(bit32.bnot(e),g))
			local temp1 = bit32.band(h0 + s1 + ch + k[i+1] + w[i], 4294967295)
			local s0 = bit32.bxor(right_rotate(a,2), right_rotate(a,13), right_rotate(a,22))
			local maj = bit32.bxor(bit32.band(a,b), bit32.band(a,c), bit32.band(b,c))
			local temp2 = bit32.band(s0 + maj, 4294967295)
			h0 = g
			g = f
			f = e
			e = bit32.band(d + temp1, 4294967295)
			d = c
			c = b
			b = a
			a = bit32.band(temp1 + temp2, 4294967295)
		end
		h[1] = bit32.band(h[1] + a, 4294967295)
		h[2] = bit32.band(h[2] + b, 4294967295)
		h[3] = bit32.band(h[3] + c, 4294967295)
		h[4] = bit32.band(h[4] + d, 4294967295)
		h[5] = bit32.band(h[5] + e, 4294967295)
		h[6] = bit32.band(h[6] + f, 4294967295)
		h[7] = bit32.band(h[7] + g, 4294967295)
		h[8] = bit32.band(h[8] + h0, 4294967295)
	end
	local digest = {}
	for i=1,8 do
		table.insert(digest, string.format("%08x", bit32.band(h[i],4294967295)))
	end
	return table.concat(digest)
end

return sha256
