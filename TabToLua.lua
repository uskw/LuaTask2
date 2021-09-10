local str_ConfigName = ""
local inInt_Level = 0   -- �ж�tab����
local keyTableAll = {}  -- ��ͷ
local luaTableAll = {}  -- ������

function tabToLua(str_TabName)
    local readFile = io.open(str_TabName..".tab", "r")

    local fileLine = readFile:read()
    local rowIndex = 1
    if fileLine ~= "" then
        splitTable(fileLine, true)  -- ��ͷ
    end
    local str_Result = setHead()
    while fileLine do
        luaTableAll = {}
        if rowIndex ~= 1 and rowIndex ~= 2 then -- ����ǰ����
            splitTable(fileLine)
            str_Result = str_Result..spliceTable(rowIndex-2)
        end
        rowIndex = rowIndex + 1
        fileLine = readFile:read()
    end
    inInt_Level = inInt_Level - 1
    local temp = ""
    for i = 1, inInt_Level, 1 do
        temp = temp .. "\t"
    end
    str_Result = str_Result .. temp .. "})"
    readFile:close()
    return str_Result
end

-- �и�tab��
function splitTable(str_TabRow, bool_IsKey)
    bool_IsKey = bool_IsKey or false
    local start = 1
    local pos = string.find(str_TabRow, "\t", start, true)
    local num = 1
    while pos ~= nil do
        local temp = {}
        local str_Name = string.sub(str_TabRow, start, pos-1)
        if bool_IsKey then  -- �����Ƿ�Ϊ��ͷ
            updateKey(str_Name, bool_IsKey)
        else
            table.insert(temp, str_Name)
            if str_Name == "" then
                table.insert(temp, false)
            else
                table.insert(temp, true)
            end
            table.insert(luaTableAll, temp)
        end
        start = pos + string.len("\t")
        pos = string.find(str_TabRow, "\t", start, true)
        num = num + 1
    end
    local str_Name = string.sub(str_TabRow, start)
    local temp = {}
    if bool_IsKey then
        updateKey(str_Name, bool_IsKey)
    else
        table.insert(temp, str_Name)
        if str_Name == "" then
            table.insert(temp, false)
        else
            table.insert(temp, true)
        end
        table.insert(luaTableAll, temp)
    end
end

-- ����s or n�ı�ͷ
function updateKey(str_Name, bool_IsKey)
    if bool_IsKey then
        local inInt_Len = string.len(str_Name)
        for i = 1, inInt_Len, 1 do
            if string.sub(str_Name, i, i) == "s" then
                if string.sub(str_Name, i+1, i+1) == "_" then
                    updateKeyTableAll(string.sub(str_Name, i+2, inInt_Len), 1)
                    return
                end
            elseif string.sub(str_Name, i, i) == "n" then
                if string.sub(str_Name, i+1, i+1) == "_" then
                    updateKeyTableAll(string.sub(str_Name, i+2, inInt_Len), 2)
                    return
                end
            end
        end
    end
end

-- ���±�ͷ
function updateKeyTableAll(str_Name, type)
    local keyValue = {}
    table.insert(keyValue, str_Name)
    table.insert(keyValue, type)
    table.insert(keyTableAll, keyValue)
end

-- ����lua�ļ�ͷ
function setHead()
    local temp = "local config = require(\"core.config\")\nlocal empty = {}\nconfig(\"" .. str_ConfigName
    local str_Result = temp .. "\",\n"
    temp = "empty,\n\n"
    str_Result = str_Result .. temp
    inInt_Level = inInt_Level + 1
    temp = ""
    for i = 1, inInt_Level, 1 do
        temp = temp .. "\t"
    end
    str_Result = str_Result .. temp .. "{\n\n"
    inInt_Level = inInt_Level + 1
    return str_Result
end

-- ƴ���ַ���
function spliceTable(inInt_Num)
    local level = inInt_Level
    local temp = ""
    for i = 1, level, 1 do  -- �ж�tab������ƴ��
        temp = temp .. "\t"
    end
    local str_Line = temp .. "[" .. luaTableAll[1][1] .. "] = {\n"
    temp = temp .. "\t"
    local num = 1
    for i = 1, #luaTableAll, 1 do
            if keyTableAll[i][2] == 1 then  -- �ж��Ƿ�Ϊstring
                str_Line = str_Line .. temp
                str_Line = str_Line..keyTableAll[i][1].." = \""..luaTableAll[i][1].."\",\n"
            elseif luaTableAll[i][2] then   -- �ж��Ƿ�Ϊint�Ҳ�Ϊ��
                str_Line = str_Line .. temp
                str_Line = str_Line..keyTableAll[i][1].." = "..luaTableAll[i][1]..",\n"
            end
        -- end
        num = num + 1
    end
    temp = ""
    for i = 1, level, 1 do
        temp = temp .. "\t"
    end
    str_Line = str_Line..temp.."},\n\n"
    return str_Line
end

-- �����lua�ļ�
function saveLuaFile(str_FileName, str_Result)
    local writeFile = io.open(str_FileName..".lua", "w")
    writeFile:write(str_Result)
    writeFile:close()
end

-- �ⲿ�ӿ�
local function createLuaFile(str_TabFileName)
    str_ConfigName = str_TabFileName
    saveLuaFile(str_TabFileName, tabToLua(str_TabFileName))
end

return createLuaFile