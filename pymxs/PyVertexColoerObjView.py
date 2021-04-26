import MaxPlus
import pymxs
from PySide2 import QtWidgets, QtCore, QtGui

rt = pymxs.runtime
rt.clearlistener()
class VertexColorObj():
    node = None
    type = None
    colorlist = []
class VertexColorView(QtWidgets.QDialog):
    targetNodes = []
    obj_fn = rt.meshop
    fnPoly = rt.Editable_Poly
    fnMesh = rt.Editable_Mesh
    fnPolyMesh = rt.PolyMeshObject
    # m_EditableMesh_str = u"Editable_mesh"
    # m_editablePoly_str = u"Editable_Poly"
    def __init__(self, parent=MaxPlus.GetQMaxMainWindow()):
        super(VertexColorView, self).__init__(parent)
        self.coler_list =[]
        self.obj_name = u""
        self.obj_type = u"ploy"
        self.setWindowTitle(u"버텍스 칼라 뷰")
        self.progress()
        self.initUI()
        self.update_UI()
    def initUI(self):
        print('initUI in')
        #UI객체
        self.text_qlabel =  QtWidgets.QLabel(u"준비중... ")
        self.color_tree_widget = QtWidgets.QTreeWidget()
        self.color_tree_widget.setExpandsOnDoubleClick(False)
        self.color_tree_widget.setHeaderLabels([u"숨김리스트",u"색상"])
        head_item = self.color_tree_widget.headerItem()
        head_item.setSizeHint(0, QtCore.QSize(500, 25))
        head_view = self.color_tree_widget.header()
        head_view.resizeSection(0, 180)
        head_view.resizeSection(1, 90)
        # myOption = QtWidgets.QStyleOptionViewItem()
        self.color_tree_widget.setFocusPolicy(QtCore.Qt.NoFocus)
        self.color_tree_widget.setSelectionMode(QtWidgets.QAbstractItemView.NoSelection)
        # self.color_tree_widget.setStyleSheet("QTreeView::item:hover:selected{border:none; border-color: blue; selection-color:rgba(255,255,255,0); background-color:rgba(255,255,255,255);}")
        # self.color_tree_widget.setStyleSheet("QTreeView::item:hover:!selected{border:none; border-color: blue; selection-color:rgba(0,255,0,0); background-color:rgba(0,255,0,255);}")
        # self.color_tree_widget.setStyleSheet("QTreeWidget::item {border:none;color:rgb(111,111,111) selection-color:rgba(255,255,255,255); background-color:rgba(255,255,255,255);}")
        # self.color_tree_widget.setStyleSheet("QTreeWidget::item:hover,QTreeWidget::item:hover:selected,QTreeWidget::item:disabled:hover, QTreeWidget::item:hover:!active{border:1px solid #6a6ea9 ;border-style:outset;border-radius:5px;}")
        # self.color_tree_widget.setStyleSheet("QTreeWidget::item:hover,QTreeWidget::item:hover:selected,QTreeWidget::item:disabled:hover, QTreeWidget::item:hover:!active{border:1px solid #6a6ea9 ;border-style:outset;border-radius:5px;background:rgba(255,255,255,255))}")

        #레이아웃
        self.main_layout = QtWidgets.QVBoxLayout()
        self.head_layout = QtWidgets.QHBoxLayout()
        self.head_layout.addWidget(self.text_qlabel)
        self.main_layout.addLayout(self.head_layout)
        self.main_layout.addWidget(self.color_tree_widget)
        self.setLayout(self.main_layout)
    def progress(self):
        isPoly = self.fnPoly
        isMesh = self.fnMesh
        isPolyMesh = self.fnPolyMesh
        for node in (rt.objects):
            # print(node.name)
            new_color_set = VertexColorObj()
            color_list = []
            obj_type = None
            if rt.isKindOf(node, isPoly):
                obj_type = isPoly
            if rt.isKindOf(node, isMesh):
                obj_type = isMesh
            if rt.isKindOf(node, isPolyMesh):
                obj_type = isPolyMesh
            if obj_type == None:
                continue
            cvp = rt.getNumCPVVerts(node.mesh)
            if  cvp > 0 and obj_type != None:
                print('is v obj')
                new_color_set.node = node
                # if obj_type == isPolyMesh:
                    # node = node.baseObject
                    # cvp = rt.getNumCPVVerts(node.mesh)
                    # obj_type = rt.classof(node)
                # print(rt.classof(node))
                if rt.isKindOf(node, isMesh):
                    for i in range(1, cvp):
                        c = rt.getVertColor(node, i)
                        color_list.append(c)
                else:
                    # if rt.isKindOf(node, isPoly):
                    # bit = node.numverts
                    node_mesh = node.mesh
                    for i in range(1, cvp):
                        # c = node.GetVertexColor(i)
                        c = rt.getVertColor(node_mesh, i)
                        color_list.append(c)
                new_color_set.type = obj_type
                new_color_set.colorlist = set(color_list)
                self.targetNodes.append(new_color_set)
    def getObjType(self, node):
        type = rt.classof(node)
        return_value = rt.meshop
        if type == u"Editable_Poly":
            return_value = rt.polyop
        return(return_value)
    def select_object(self):
        for node in rt.selection:
            if rt.isKindOf(node, rt.Editable_Poly) or rt.isKindOf(node, rt.Editable_Mesh):
                self.targetNodes.append(node)
        self.select_name_label.setText(self.targetNodes[0].name)
        #GetObjVertsColor 선택한 오브젝트의 버텍스 칼라 얻어오기
        #칼라정보, 버택스 리스트
    def GetColorByObj(self, node):
        pass
    def SetHideFace(self, node, vert_array):
        objop = self.getObjType(node)
        face_bitArray = objop.getFacesUsingVert(node, vert_array)
        objop.setHiddenFaces(node, face_bitArray)
    def update_UI(self):
        pass
        for color_set in self.targetNodes:
            item = QtWidgets.QTreeWidgetItem(self.color_tree_widget)
            item.setExpanded(True)
            print(color_set.node)
            obj_name = color_set.node.name
            item.setText(0, obj_name)
            for color_value in color_set.colorlist:
                sub_item = QtWidgets.QTreeWidgetItem(item)
                sub_item.setCheckState(0, QtCore.Qt.Unchecked )
                sub_item.setTextColor(0,QtGui.QColor(255, 255, 255))
                sub_item.setText(0, str(color_value))
                color_qbrush = QtGui.QBrush(QtGui.QColor(color_value.r, color_value.g, color_value.b))
                # sub_item.setBackground(1, color_qbrush)
                map = QtGui.QPixmap(15,15)
                map.fill(QtGui.QColor(color_value.r, color_value.g, color_value.b))
                icon = QtGui.QIcon(map)
                sub_item.setIcon(1,icon)
                # img = QtGui.QImage()
                # color_img = QtGui.QBrush(QtGui.QPixmap(img.setPixel(100, 100,255)))
                # sub_item.setForeground(1, color_qbrush)
                # sub_item.setText(1, backup_file_set.number_str )
    def update_color_table(self, ):
        pass
    def testData(self):
        pass

VertexColorView().show()