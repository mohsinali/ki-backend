var config = {
  apiKey: gon.FIREBASE['API_KEY'],
  authDomain: gon.FIREBASE['AUTH_DOMAIN'],
  databaseURL: gon.FIREBASE['DATABASE_URL'],
  projectId: gon.FIREBASE['PROJECT_ID'],
  storageBucket: gon.FIREBASE['STORAGE_BUCKET'],
  messagingSenderId: gon.FIREBASE['MESSAGING_SENDER_ID']
};

firebase.initializeApp(config);

var defaultStorage  = firebase.storage();
var defaultDatabase = firebase.database();

// var userId = firebase.auth().currentUser.uid;
var roomKeys        = [];
var rooms           = [];
var chatKeys        = [];
var chatMessages    = [];
var organization_id = window.location.href.split('/')[4];

var chatRoomsRef = defaultDatabase.ref('/chat-room')
    .orderByChild('organisation_id')
    .equalTo(organization_id);

chatRoomsRef.on("child_added", function(snapshot) { 
    roomHashes = snapshot.val();

    addRoom(roomHashes);
    chatRoom(organization_id, roomHashes.sender_id)
});

chatRoomsRef.on("child_changed", function(snapshot) { 
    
    roomHashes = snapshot.val();

    updateRoom(roomHashes);
});

function addRoom(room) {
    sender_id = room.sender_id;
    message = returnLastMessage(room.messages);
    $.ajax({
      datatype: "json",
      type: 'GET',
      url: '/organizations/'+ organization_id +'/ongoing_chat',
      data: { message_obj: message, sender_id: sender_id },
      success: function(data){
        $(".ongoing_chats").append(data)
      }
    });
}

function updateRoom(room) {
  sender_id = room.sender_id;
  message = returnLastMessage(room.messages);

  $("#cr-" + organization_id + '-' + sender_id).html('');
  $("#cr-" + organization_id + '-' + sender_id).html(message.message);
  
  if ($(".chat-class").attr('data-sender-id') === sender_id) {
    chatRoom(organization_id, sender_id);
  }
}

function chatRoom(organization_id, sender_id) {  
  $('.select-chat-text').removeClass('select-chat-user');
  $('#select-user-chat_' + sender_id).addClass('select-chat-user');
  $('.updated-chat').removeClass('select-user-chat-p');
  $("#cr-" + organization_id + '-' + sender_id).addClass('select-user-chat-p')
  
  return defaultDatabase.ref('/chat-room/cr-' + organization_id + '-' + sender_id + '/messages/').once('value').then(function(snapshot) {

    chatRoomMessages = snapshot.val();
    chatMessages = [];
    for (var message in chatRoomMessages) {
        chatKeys.push(message);
        chatMessages.push(chatRoomMessages[message]);
    }
  }).then(printMessages)
    // .then(scrollTopChat);
}

function printMessages() {
  $.ajax({
    datatype: "json",
    type: 'GET',
    url: '/organizations/'+ organization_id +'/chat',
    data: { chat_messages: chatMessages, organization_id: organization_id, sender_id: sender_id },
    success: function(data){
      $(".users-chat-box").html("");
      $(".users-chat-box").html(data);
      scrollTopChat();
    }
  });
}

function scrollTopChat() {
  const chatClass = $(".chat-class");
  $(".users-chat-box").animate({ scrollTop: chatClass[chatClass.length - 1].offsetTop }, 'slow');
}

function trackMessages(roomMessages) {
  roomMessageKeys = [];
  roomMessageVals = [];
  
  for (var roomMessage in roomMessages) {
      roomMessageKeys.push(roomMessage);
      roomMessageVals.push(roomMessages[roomMessage]);
  }

  return roomMessageVals;
}

function returnLastMessage(roomMessages) {
  messages = trackMessages(roomMessages);
  return messages[messages.length - 1];
}

$(document).on("click",".send-data", function() {
  organization_id   = $(this).attr('data-organization-id');
  organization_name = $(this).attr('data-organization-name');
  sender_id         = $(this).attr('data-sender-id');
  textarea          = $("#messanger_" + organization_id + "_" + sender_id).find( "textarea" );
  message           = textarea.val();

  var newPostRef = defaultDatabase.ref('/chat-room/cr-' + organization_id + '-' + sender_id + '/messages/').push();
  if (message !== '') {
    newPostRef.set({
        "message": message,
        "senderName": organization_name,
        "senderType": "O",
        "timeStamp": new Date().getTime()
    });
    textarea.val('');
  }
});

$(document).on("keyup", ".text-area", function(event) {
    if (event.keyCode === 13 && !event.shiftKey) {
        send_button = $('#ta-btn-' + $(this).attr("data-sender-id") + '_' +$(this).attr("data-organization-id"))
        send_button.click();
    }
});
 

document.addEventListener('scroll', function (event) {
    if ($(event.target).hasClass('users-chat-box')) {    
      if($(event.currentTarget).scrollTop() == $(document).height() - $(event.currentTarget).height()) {
          //  debugger;
      }
    }
}, true);

// $(".users-chat-box").on('scroll', function() {
//     debugger;
//     // console.log('hedfklsdj');
//     // if($('.right-side-chat').scrollTop() == $(document).height() - $('.users-chat-box').height()) {
//     //        debugger;
//     // }
// });

$(document).on("click",".user-add-chat",function() {
  organization_id = $(this).attr('data-organization-id');
  sender_id       = $(this).attr('data-sender-id');

  chatRoom(organization_id, sender_id);
});

$(function(){
  $('.def-txt-input').keypress(function(e){
    // allowed char: 1 , 2 , 3, 4, 5, 6, 7, A, B, C
    let allow_char = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57];
    if(allow_char.indexOf(e.which) !== -1 ){
      //do something
    }
    else{
      return false;
    }
  });
  
  $("input").keyup(function(){ 
    // debugger
    if (Number.isInteger(parseInt(this.value))){
      id = parseInt(this.id) + 1; 
      $("input[id="+id+"]").focus();
      if (id == 7){
        submit_form();
      }  
    }
  })
  // var inputs = document.querySelectorAll("#activate_code input[name='chars[]']");
  // inputs.forEach(function(input){
  // })
  //   $("input[name='chars[1]'").focus();
  //   //$("input[name='chars[1]'").text(i += 1);
  // });
  
  // $("input[name='chars[1]'").keypress(function(){
  //   $("input[name='chars[2]'").focus();
  //   //$("input[name='chars[1]'").text(i += 1);
  // });
});
function submit_form(){
  event.preventDefault();
  var id = $('#active-btn')
  var ar = []
  var inputs = document.querySelectorAll("#activate_code input[name='chars[]']");
  inputs.forEach(function(input){
    if (input.value != ""){
      ar.push(input.value)
      // your code here
    }
  })
  $.ajax({
    datatype: "json",
    type: 'GET',
    url: $('form').attr("action"),
    data: {id: id[0].name, chars: ar},
    success: function(data){
      if (data.bool == false){
        alert("Please enter valid access code");
      }
      else{
        $('#activate_code').submit();
      }
    }
  });
}
function create_faq(){
  event.preventDefault();
  var que = $('#create_faq_question')
  var ans = $('#create_faq_answer')
  if (que.val() && ans.val()){
    $.ajax({
      datatype: "json",
      type: 'POST',
      url: $('#faq_create').attr("action"),
      data: {que: que.val(), ans: ans.val(), broadband_id: $('#faq_create').attr("name") }
    });
  }
  else{
    alert("Please fill the fields");
  }
}
function delete_faq(id, broadband_id){

  $.ajax({
    datatype: "json",
    type: 'DELETE',
    url: '/organizations/faq/'+id,
    data: {id: id, broadband_id: broadband_id},
    success: function(data){
      if (data.bool){
        $('#accordion'+data.bool).remove()
        alert("Faq has been deleted")
      }
    }
  });
}

function update_faq(id, broadband_id){

  que = $('#update_question_'+id).val()
  ans = $('#update_answer_'+id).val()
  $.ajax({
    datatype: "json",
    type: 'PUT',
    url: '/organizations/faq/'+id,
    data: {id: id, broadband_id: broadband_id, que: que, ans: ans},
    success: function(data){
      if (data){
        alert("Faq has been updated")
      }
    }
  });
}
