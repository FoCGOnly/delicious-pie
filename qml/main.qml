import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.0
import QtQuick.LocalStorage 2.0
import "settings.js" as LocalSettings

ApplicationWindow {
	id: app
	visible: true
	
	width: 800
	height: 600
	
	menuBar: MenuBar {
		Menu {
			title: "File"
			MenuItem {
				text: "Save"
				shortcut: "Ctrl+S"
				onTriggered: app.saveDoc()
			}
			MenuItem {
				text: "Open"
				shortcut: "Ctrl+O"
				onTriggered: app.openDoc()
			}
			MenuItem {
				text: "run"
				shortcut: "Ctrl+R"
				onTriggered: mainApp.runDocument(tabView.getTab(tabView.currentIndex).item.textDocument)
			}
			MenuItem {
				text: "Quit"
				shortcut: "Ctrl+Q"
				onTriggered: Qt.quit()
			}
		}
		Menu {
			title: "Help"
			MenuItem {
				text: "About..."
				shortcut: "Ctrl+H"
				onTriggered: app.about()
			}
		}
	}
	
	TabView {
		id: tabView
		anchors.fill: parent
	}
	
	Component {
		id: editorComponent
		CodeEditor {
			anchors.fill: parent
		}
	}
	
	Component.onCompleted: {
		var myDb = LocalSettings.openDatabase()
		var tabName = LocalSettings.getSettingValue(myDb, "LastFile")
		if (!tabName) {
			tabView.addTab("untitled.py", editorComponent)
			return
		}
		var myTab = tabView.addTab(tabName, editorComponent)
		
		myTab.onLoaded.connect(function(){
			mainApp.loadFile(myTab.item.textDocument, tabName)
		})
	}
	
	Component.onDestruction: {
		var myDb = LocalSettings.openDatabase()
		LocalSettings.setSettingValue(myDb, "LastFile", tabView.getTab(tabView.currentIndex).item.openUrl)
	}
	
	Rectangle {
		id: aboutView
		visible: false
		z: 1
		
		anchors.fill: parent
		color: "green"
		state: "off"
		
		MouseArea {
			anchors.fill: aboutView
			onClicked: aboutView.state = "off"
			cursorShape: Qt.ArrowCursor
		}
		Rectangle {
			id: innerAboutRect
			
			anchors.centerIn: parent
			width: 250
			height: 100
			color: "white"
			border.color: "black"
			opacity: 1
			Text {
				anchors.fill: parent
				anchors.margins: 4
				text: "Simple Python IDE for beginners <br> by Jagh, 2013"
			}
		}
		
		states: [ State {
			name: "off"
			PropertyChanges { target: aboutView; opacity: 0 }
			PropertyChanges { target: aboutView; enabled: false }
		}, State {
			name: "on"
			PropertyChanges { target: aboutView; opacity: 0.5 }
			PropertyChanges { target: aboutView; enabled: true } 
			PropertyChanges { target: centralEditor; enabled: false }
		} ]
		transitions: Transition {
			from: "off"; to: "on"
			NumberAnimation { properties: "opacity"; duration: 500 }
		}
	}
	
	FileDialog {
		id: fileChooser
		title: "Choose where to save the file"
		nameFilters: "*.py"
		selectExisting: false
		selectFolder: false
		selectMultiple: false
		
		onAccepted: {
			mainApp.saveDocument(tabView.getTab(tabView.currentIndex).item.textDocument, fileUrl)
			var tabName = fileUrl.toString()
			tabName = tabName.slice(tabName.lastIndexOf("/") + 1)
			tabView.getTab(tabView.currentIndex).title = tabName
		}
	}
	
	FileDialog {
		id: fileOpener
		title: "Select a file to be opened"
		nameFilters: "*.py"
		selectExisting: true
		selectFolder: false
		selectMultiple: false
		
		onAccepted: {
			var tabName = fileUrl.toString()
			tabName = tabName.slice(tabName.lastIndexOf("/") + 1)
			var myTab = tabView.addTab(tabName, editorComponent)
			print(myTab)
			myTab.onLoaded.connect(function(){
				mainApp.loadFile(myTab.item.textDocument, fileUrl)
			})
			tabView.currentIndex = tabView.count - 1
		}
	}
	
	function about() {
		aboutView.visible = true
		aboutView.state = "on"
	}
	
	function saveDoc() {
		fileChooser.open()
	}
	
	function openDoc() {
		fileOpener.open()
	}
}
