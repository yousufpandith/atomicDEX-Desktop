import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

// Open Enable Coin Modal
Popup {
    id: root
    anchors.centerIn: Overlay.overlay
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    onClosed: if(stack_layout.currentIndex === 2) reset(true)

    // Local
    readonly property var default_prepare_send_result: ({ has_error: false, error_message: "", tx_hex: "", date: "", fees: "", explorer_url: "" })
    property var prepare_send_result: default_prepare_send_result
    property string send_result

    function prepareSendCoin(address, amount) {
        prepare_send_result = API.get().prepare_send(address, amount, parseFloat(API.get().current_coin_info.balance) === parseFloat(amount))

        if(prepare_send_result.has_error) {
            text_error.text = prepare_send_result.error_message
        }
        else {
            text_error.text = ""

            // Change page
            stack_layout.currentIndex = 1
        }
    }

    function sendCoin() {
        send_result = API.get().send(prepare_send_result.tx_hex)
        stack_layout.currentIndex = 2
    }

    function reset(close = false) {
        prepare_send_result = default_prepare_send_result
        send_result = ""

        input_address.field.text = ""
        input_amount.field.text = ""
        text_error.text = ""

        if(close) root.close()
        stack_layout.currentIndex = 0
    }

    // Inside modal
    StackLayout {
        id: stack_layout

        // Prepare Page
        ColumnLayout {
            Layout.fillWidth: true

            ModalHeader {
                title: qsTr("Prepare to Send")
            }

            // Send address
            AddressField {
                id: input_address
                title: qsTr("Recipient's address")
                field.placeholderText: qsTr("Enter address of the recipient")
            }

            // Amount input
            AmountField {
                id: input_amount
                title: qsTr("Amount to send")
                field.placeholderText: qsTr("Enter the amount to send")
            }

            DefaultText {
                id: text_error
                color: Style.colorRed
                visible: text !== ''
            }

            // Buttons
            RowLayout {
                Button {
                    text: qsTr("Close")
                    Layout.fillWidth: true
                    onClicked: root.close()
                }
                Button {
                    text: qsTr("Prepare")
                    Layout.fillWidth: true

                    enabled: input_address.field.text != "" &&
                             input_amount.field.text != "" &&
                             input_address.field.acceptableInput &&
                             input_amount.field.acceptableInput

                    onClicked: prepareSendCoin(input_address.field.text, input_amount.field.text)
                }
            }
        }

        // Send Page
        ColumnLayout {
            ModalHeader {
                title: qsTr("Send")
            }

            // Address
            TextWithTitle {
                title: qsTr("Recipient's address:")
                text: input_address.field.text
            }

            // Amount
            TextWithTitle {
                title: qsTr("Amount:")
                text: General.formatCrypto(input_amount.field.text, API.get().current_coin_info.ticker)
            }

            // Fees
            TextWithTitle {
                title: qsTr("Fees:")
                text: General.formatCrypto(prepare_send_result.fees, API.get().current_coin_info.ticker)
            }

            // Date
            TextWithTitle {
                title: qsTr("Date:")
                text: prepare_send_result.date
            }

            // Buttons
            RowLayout {
                Button {
                    text: qsTr("Back")
                    Layout.fillWidth: true
                    onClicked: stack_layout.currentIndex = 0
                }
                Button {
                    text: qsTr("Send")
                    Layout.fillWidth: true
                    onClicked: sendCoin()
                }
            }
        }

        // Result Page
        ColumnLayout {
            ModalHeader {
                title: qsTr("Transaction Complete!")
            }

            // Address
            TextWithTitle {
                title: qsTr("Recipient's address:")
                text: input_address.field.text
            }

            // Amount
            TextWithTitle {
                title: qsTr("Amount:")
                text: General.formatCrypto(input_amount.field.text, API.get().current_coin_info.ticker)
            }

            // Fees
            TextWithTitle {
                title: qsTr("Fees:")
                text: prepare_send_result.fees
            }

            // Date
            TextWithTitle {
                title: qsTr("Date:")
                text: prepare_send_result.date
            }

            // Transaction Hash
            TextWithTitle {
                title: qsTr("Transaction Hash:")
                text: send_result
            }

            // Buttons
            RowLayout {
                Button {
                    text: qsTr("Close")
                    Layout.fillWidth: true
                    onClicked: reset(true)
                }
                Button {
                    text: qsTr("View at Explorer")
                    Layout.fillWidth: true
                    onClicked: Qt.openUrlExternally(prepare_send_result.explorer_url + "tx/" + send_result)
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
