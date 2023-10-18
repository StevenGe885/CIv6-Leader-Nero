-- Rome_Nero_Effect
-- Author: get19
-- DateCreated: 7/5/2022 12:11:06 AM
--------------------------------------------------------------
print("Rome_Nero_Effect.lua initiated")
local ce_limit = {CE1 = 1, CE2 = 1, CE3 = 1, CE4 = 1, CE5 = 1, CE6 = 1, CE7 = 1, CE8 = 1, CE9 = 1}
local servant_limit = {VV = 1}

function OnNeroFestCompleted(iPlayerID, iCityID, iProjectID, buildingIndex, iX, iY, bCancelled)
	print("completed project: ", GameInfo.Projects[iProjectID].Name)
	--local pPlayer = Players[0]	
	--local pCity = CityManager.GetCity(0, 0)	
	--local iBuilding = GameInfo.Buildings["BUILDING_NERO_DUMMY"].Index
	--local iCityPlotIndex = Map.GetPlot(pCity:GetX(), pCity:GetY()):GetIndex()
	--pCity:GetBuildQueue():CreateIncompleteBuilding(iBuilding, iCityPlotIndex, 100)
	--Players[0]:GetTreasury():ChangeGoldBalance(100)
	--Players[0]:GetCulture():ChangeCurrentCulturalProgress(100)
	--Players[0]:GetTechs():ChangeCurrentResearchProgress(100)
	
	local pPlayer = Players[iPlayerID]	
	local pCity = CityManager.GetCity(iPlayerID, iCityID)
	local iCityPlotIndex = Map.GetPlot(pCity:GetX(), pCity:GetY()):GetIndex()
	local iBuilding = GameInfo.Buildings["BUILDING_NERO_DUMMY"].Index
	if (GameInfo.Projects[iProjectID].Name == "LOC_PROJECT_NERO_FEST_NAME") then
		print("if statement triggered")
		local pAmenity = pCity:GetGrowth():GetAmenities()
		pPlayer:GetTreasury():ChangeGoldBalance(pAmenity*5)
		pPlayer:GetCulture():ChangeCurrentCulturalProgress(pAmenity*5)
		for i = 1, pAmenity, 1 do
			pCity:GetBuildQueue():CreateIncompleteBuilding(iBuilding, iCityPlotIndex, 100)
		end

		--pPlayer:AttachModifierByID("GOODY_CULTURE_GRANT_ONE_RELIC")
	end
end

function OnTurnStartRemoveDummy(iPlayerID)
	--print("start triggered for player ", iPlayerID)
	local pPlayer = Players[iPlayerID]
	local pLeader = PlayerConfigurations[iPlayerID]:GetLeaderTypeName()  

	if pLeader == "LEADER_NERO" then
		local pCities = pPlayer:GetCities();
		local iBuilding = GameInfo.Buildings["BUILDING_NERO_DUMMY"].Index
		--local pCity = CityManager.GetCity(iPlayerID, 0)	
		for i, pCity in pCities:Members() do
			if pCity:GetBuildings():HasBuilding(iBuilding) then
				pCity:GetBuildings():RemoveBuilding(iBuilding)
			end
		end
	end
end

function OnNeroDistrictComplete(iPlayerID, iDistrictID, iCityID, iX, iY, districtType, era, civilization, percentComplete, iAppeal, isPillaged)
	local pPlayer = Players[iPlayerID]
	local pLeader = PlayerConfigurations[iPlayerID]:GetLeaderTypeName()
	local pCity = CityManager.GetCity(iPlayerID, iCityID)
	local iDistrictPlotIndex = Map.GetPlot(iX, iY):GetIndex()

	if (pLeader == "LEADER_NERO" and percentComplete == 100) then
		print("district type completed: ", districtType)
		local m_yieldCap = 16
		local districtCount = 0
		local districtOldCount = 0
		local pCities = pPlayer:GetCities();
		local iBuilding = GameInfo.Buildings["BUILDING_NERO_DUMMY"].Index
		local ModifierId = "TRAIT_NERO_WRITING"
		-- campus2, theater8, holysite1, commercial6, industry9, harbor4
		-- identify which district is built and set the variables
		if districtType == 2 then
			iBuilding = GameInfo.Buildings["BUILDING_NERO_CAMPUS_DUMMY"].Index
			ModifierId = ModifierId .. "_CAMPUS"
		elseif districtType == 8 then
			iBuilding = GameInfo.Buildings["BUILDING_NERO_THEATER_DUMMY"].Index
			ModifierId = ModifierId .. "_THEATER"
		elseif districtType == 1 then
			iBuilding = GameInfo.Buildings["BUILDING_NERO_HOLYSITE_DUMMY"].Index
			ModifierId = ModifierId .. "_HOLYSITE"
		elseif districtType == 6 then
			iBuilding = GameInfo.Buildings["BUILDING_NERO_COMMERCIAL_DUMMY"].Index
			ModifierId = ModifierId .. "_COMMERCIAL"
		elseif districtType == 9 then
			iBuilding = GameInfo.Buildings["BUILDING_NERO_INDUSTRY_DUMMY"].Index
			ModifierId = ModifierId .. "_INDUSTRY"
		elseif districtType == 4 then
			iBuilding = GameInfo.Buildings["BUILDING_NERO_HARBOR_DUMMY"].Index
			ModifierId = ModifierId .. "_HARBOR"
		end
		print("current ModifierId: ", ModifierId)

		-- this function only takes effect on certain districts
		if ModifierId ~= "TRAIT_NERO_WRITING" then
			-- count already built districts and newly built districts, avoid counting unfinished districts
			-- this is needed to know exactly which negative and positive modifier to attach since multiple districts can be built at the same time
			for i, pCity in pCities:Members() do
				if (pCity:GetDistricts():HasDistrict(districtType) and pCity:GetDistricts():GetDistrict(districtType):IsComplete()) then
					districtCount = districtCount + 1
					if pCity:GetBuildings():HasBuilding(iBuilding) then
						districtOldCount = districtOldCount + 1
					else
						local iCityPlotIndex = Map.GetPlot(pCity:GetX(), pCity:GetY()):GetIndex()
						pCity:GetBuildQueue():CreateIncompleteBuilding(iBuilding, iCityPlotIndex, 100)
					end
				end
			end
			print("district old count: ", districtOldCount)
			print("district count: ", districtCount)

			-- attach modifiers
			if (districtOldCount < m_yieldCap and districtOldCount ~= districtCount) then
				-- cap at 16
				if districtCount > m_yieldCap then
					districtCount = m_yieldCap
				end

				local ModifierPosId = ModifierId .. "_POS_" .. districtCount
				local ModifierNegId = ModifierId .. "_NEG_" .. districtOldCount
				if districtOldCount == 0 then
					pPlayer:AttachModifierByID(ModifierPosId)
					print("attached modifier: ", ModifierPosId)
				else
					pPlayer:AttachModifierByID(ModifierNegId)
					pPlayer:AttachModifierByID(ModifierPosId)
					print("attached modifier: ", ModifierPosId)
					print("attached modifier: ", ModifierNegId)
				end
			end

		end
	end
end

function GreatWriterGiveModifier(iPlayerID, iUnitID, iX, iY, iBuildingID, iGreatWorkID)
	--print("great work produced ", GameInfo.Greatworks[iGreatWorkID].Name)
end

Events.CityProjectCompleted.Add(OnNeroFestCompleted)
Events.GreatWorkCreated.Add(GreatWriterGiveModifier)
Events.DistrictBuildProgressChanged.Add(OnNeroDistrictComplete)
GameEvents.PlayerTurnStartComplete.Add(OnTurnStartRemoveDummy)