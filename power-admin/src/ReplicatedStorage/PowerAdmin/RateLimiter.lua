--!strict
local RunService = game:GetService("RunService")

local RateLimiter = {}

export type TokenBucket = {
	capacity: number,
	tokens: number,
	refillPerSecond: number,
	lastRefill: number,
}

local function now(): number
	return os.clock()
end

local function createBucket(capacity: number, perMinute: number): TokenBucket
	local perSecond = perMinute / 60
	return {
		capacity = capacity,
		tokens = capacity,
		refillPerSecond = perSecond,
		lastRefill = now(),
	}
end

local function take(bucket: TokenBucket, tokens: number): boolean
	local t = now()
	local elapsed = t - bucket.lastRefill
	bucket.lastRefill = t
	bucket.tokens = math.min(bucket.capacity, bucket.tokens + elapsed * bucket.refillPerSecond)
	if bucket.tokens >= tokens then
		bucket.tokens -= tokens
		return true
	end
	return false
end

function RateLimiter.createUserLimiter(perMinute: number)
	local userIdToBucket: { [number]: TokenBucket } = {}
	return function(userId: number, cost: number?): boolean
		local bucket = userIdToBucket[userId]
		if not bucket then
			bucket = createBucket(perMinute, perMinute)
			userIdToBucket[userId] = bucket
		end
		return take(bucket, cost or 1)
	end
end

return RateLimiter

