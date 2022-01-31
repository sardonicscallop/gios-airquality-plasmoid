import QtQuick 2.7
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import "logic.js" as Logic

Item
{

    property string plasmoidLabelText: Plasmoid.configuration.plasmoidLabel

    property string airQualityIndexString: i18n("n/a")
    onAirQualityIndexStringChanged: airQualityIndexLabel.text = airQualityIndexString;
    property string sensorName: null
    property string timeIndexCalculated: null
    property var sensorsIdList: Plasmoid.configuration.sensorsIdList


    Plasmoid.icon: "plasmapackage:/images/icon-light/update-none.svg"
    width: 320
    height: 240


    GridLayout
    {
        anchors.fill: parent
        rows: 3
        columns: 2


        PlasmaCore.IconItem
        {
            id: airQualityIcon
            width: PlasmaCore.Units.iconSizes.huge
            Layout.fillWidth: true
            Layout.column: 0
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 3
            Layout.preferredWidth: PlasmaCore.Units.iconSizes.huge
            Layout.preferredHeight: PlasmaCore.Units.iconSizes.huge
            source: "update-none"

        }

        Text
        {
            id: plasmoidLabel
            Layout.fillWidth: true
            Layout.column: 1
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 1
            text: plasmoidLabelText
            topPadding: 3
            horizontalAlignment: Text.AlignHCenter
            color: PlasmaCore.Theme.textColor
        }

        Text
        {
            id: airQualityIndexLabel
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.column: 1
            Layout.columnSpan: 1
            Layout.row: 1
            Layout.rowSpan: 1
            text: i18n("n/a")
            font.weight: Font.Normal
            font.pointSize: 36
            padding: 5
            minimumPointSize: 10
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            color: PlasmaCore.Theme.textColor
        }

        Text {
            id: timeSensorReadingLabel
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.column: 1
            Layout.columnSpan: 1
            Layout.row: 2
            Layout.rowSpan: 1
            text: i18n("Calculated for: ") + timeIndexCalculated
            horizontalAlignment: Text.AlignHCenter
            anchors.bottom: parent.bottom


            color: PlasmaCore.Theme.textColor

        }
    }

    MouseArea
    {
        anchors.fill: parent;
        onClicked: {
            fetchData();
        }

        PlasmaCore.ToolTipArea
        {
            anchors.fill: parent
            subText: {
                i18n("Air quality: ") + airQualityIndexString + "\n" +
                i18n("Calculated for: ") + timeIndexCalculated + "\n" +
                i18n("Sensor name: ") + sensorName
            }
        }
    }

    Timer
    {
        id: textTimer
        interval: plasmoid.configuration.updateInterval * 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: fetchData()
    }

    function resetPlasmoid()
    {
        airQualityIndexString = i18n("n/a");
        airQualityIndexLabel.color = "gray";
    }

    function fetchData()
    {
        resetPlasmoid();
        var xmlhttp = new XMLHttpRequest();

        xmlhttp.onreadystatechange=function()
        {
            if(xmlhttp.readyState === XMLHttpRequest.DONE && xmlhttp.status === 200)
            {
                var data = JSON.parse(xmlhttp.responseText);

                // Api starts from -1, but this array – from 0 => remember that when you reference to this array
                var statusStrings = [ i18n("n/a"), i18n("very bad"), i18n("bad"), i18n("adequate"), i18n("moderate"), i18n("good"), i18n("very good") ];
                var statusColors = [ "gray", "darkred", "red", "orange", "yellow", "darkgreen", "green" ]


                airQualityIndexString = statusStrings[data.stIndexLevel.id + 1];
                airQualityIndexLabel.color = statusColors[data.stIndexLevel.id + 1];
                timeIndexCalculated = data.stSourceDataDate;
            }
        }

        xmlhttp.open("GET", Plasmoid.configuration.giosServerAdress + "/aqindex/getIndex/" + Plasmoid.configuration.stationId );
        xmlhttp.send();
    }
}
