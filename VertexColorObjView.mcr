macroScript VertexColorMeshView

category:"_AniSeoHyun"
tooltip:"버텍스칼라 모델뷰"
icon:#("",0)
(
-- 오브젝트에 사용된 버텍스 칼라 색갈별로 리스트 생성
-- 해당 리스트를 클릭하면 해당 버택스 선택
-- 버택스를 페이스로 변환후 하이드/언하이드

rollout VertexColorView_rollout "모델 등급 보기" width:250 height:130
(
    -- 설정값
    local m_targetHide_color = color 255 0 0  --숨김처리하는 버텍스칼라
    local m_target_nodeArray = #()

    -- ui 설정값
    group "설정"(
        colorpicker ui_hideColor "숨김처리할 색:" color:[255,0,0] modal:true align:#center
        button ui_selectMesh "선택" across:2 align:#center tooltip:"적용할 Mesh나 Poly를 선택합니다."
        label ui_selectName "선택 : 없음" align:#left
    )
    group "실행"(
        button ui_hideMeshOn "하이드" across:2 tooltip:"지정된 색이 적용된 버택스쉐이더 면을 숨깁니다."
        button ui_hideMeshOff "언하이드" tooltip:"면 숨김을 풉니다."
    )
    
    --다른 함수 영향을 안받는 순수 셈
    fn SetHideFace_bool obj_node:undefined vert_intArray:#() = (
        face_bitArray = meshop.getFacesUsingVert obj_node vert_intArray
        meshop.setHiddenFaces obj_node face_bitArray
        update obj_node
        true
    )
    fn UpdateMTargetNodeArray_fn obj_nodeArray:(selection as array)= (
        m_target_nodeArray = #()
        for obj_node in obj_nodeArray do (
            if (isKindOf obj_node Editable_mesh) or (isKindOf obj_node Editable_Poly) do (
                append m_target_nodeArray obj_node
            )
        )
        m_target_nodeArray
    )
    fn UpdateUIselectName_fn = (
        uiName_StringStream = StringStream ""
        append uiName_StringStream "선택 : "
        for obj_node in m_target_nodeArray do (
            append uiName_StringStream obj_node.name
            append uiName_StringStream ", "
        )
        if m_target_nodeArray.count == 0 do append uiName_StringStream "없음"
        temp_string = uiName_StringStream as string
        free uiName_StringStream

        ui_selectName.text = trimright temp_string ", "
    )
    fn CheckIsValidArray_bool target_nodeArray:#() = (
        isfalseNode_bool = false
        for obj_node in target_nodeArray do (
            if not isValidNode obj_node do (
                isfalseNode_bool = true
            )
        )
        not isfalseNode_bool
    )

    -- 연계 셈
    fn UpdateHideMeshArray_fn obj_nodeArray:(selection as array)= (
        UpdateMTargetNodeArray_fn obj_nodeArray:obj_nodeArray
        UpdateUIselectName_fn()
    )
    fn CheckIsNodeArray_fn target_nodeArray:#() =(
        isValid_bool = CheckIsValidArray_bool target_nodeArray:target_nodeArray
        if not isValid_bool do (
            UpdateHideMeshArray_fn()
        )
    )
    fn RunLowMesh_fn target_nodeArray:(objects as array) = (
        -- Mesh인지 poly인지 체크
        for obj_node in target_nodeArray do (
            --print obj_node.name
            modPanel.setCurrentObject obj_node.baseObject
            if (isKindOf obj_node Editable_mesh) do (
                verts_BitArray = meshop.getVertsByColor obj_node m_targetHide_color 0 0 0
                SetHideFace_bool obj_node:obj_node vert_intArray:verts_BitArray
                update obj_node
            )
            if (isKindOf obj_node Editable_Poly) do (
                vet_bitArray = polyop.getVertsByColor obj_node m_targetHide_color 0 0 0
                face_bitArray = polyop.getFacesUsingVert obj_node vet_bitArray
                polyop.setHiddenFaces obj_node face_bitArray
                update obj_node
            )
        )
    )

    -- ui 셈
    on ui_hideColor changed pick_color do (
        m_targetHide_color = pick_color
    )
    on ui_selectMesh pressed do (
        UpdateHideMeshArray_fn()
    )
    on ui_hideMeshOn pressed do (
        CheckIsNodeArray_fn target_nodeArray:m_target_nodeArray
        sel_nodeArray = (selection as array)
        clearSelection()
        RunLowMesh_fn target_nodeArray:m_target_nodeArray
        redrawViews() 
        clearSelection()
        select sel_nodeArray
    )
    on ui_hideMeshOff pressed do (
        CheckIsNodeArray_fn target_nodeArray:m_target_nodeArray
        sel_nodeArray = (selection as array)
        clearSelection()
        for obj_node in m_target_nodeArray do (
            modPanel.setCurrentObject obj_node.baseObject
            if (isKindOf obj_node Editable_mesh) do (
                SetHideFace_bool obj_node:obj_node
            )
            if (isKindOf obj_node Editable_Poly) do (
                polyop.unHideAllFaces obj_node 
            )
        )
        redrawViews()
        clearSelection()
        select sel_nodeArray
    )
    on VertexColorView_rollout open do (
        UpdateHideMeshArray_fn()
    )
)
if VertexColorView_rollout != undefined do (
    DestroyDialog  VertexColorView_rollout
)
createDialog VertexColorView_rollout  style:#(#style_toolwindow, #style_sysmenu, #style_resizing)
)