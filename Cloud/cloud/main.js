// Use Parse.Cloud.define to define as many cloud functions as you want.

Parse.Cloud.define("addFriendToFriendsRelation", function(request,response) {
    Parse.Cloud.useMasterKey();
    
    var friendRequestId = request.params.friendRequest;
    var query = new Parse.Query("FriendRequest");
    
    // get the friend request object
    query.get(friendRequestId, {
       success: function(friendRequest) {
           
           // get the user the request was from
           var fromUser = friendRequest.get("from");
           
           // get the user the request is to
           var toUser = friendRequest.get("to");
           
           var relation = fromUser.relation("Friendship");
           relation.add(toUser);
           
           fromUser.save(null, {
               success: function() {
                   friendRequest.set("status", "accepted");
                   
                   friendRequest.save(null, {
                       success: function() {
                           response.success("saved relation and updated friendRequest");
                       },
                       error: function(error) {
                           response.error(error);
                       }
                   });
               },
               error: function(error) {
                   response.error(error);
               }
           });
       }, 
        error: function(error) {
            response.error(error);
        }
    });
});

Parse.Cloud.define("sendPushToUser", function(request, response){
    var senderUser = request.user;
    var recipientUserId = request.params.recipientId;
    var message = request.params.message;
    var location = request.params.location;
    var pushNotificationType = request.params.pushNotificationType;
    
    // Validate that the sender is allowed to send to the recipient
    // Recipient must be a "friend" of the sender
    var userFriends = senderUser.relation("Friendship");
    var relationQuery = userFriends.query()
    relationQuery.get(recipientUserId, {
        error: function(object, error) {
          response.error("The recipient is not the user's friend, cannot send push.");  
        }
    });
    
    // Validate the message text in some way
    
    // Send the push
    // Find the devices associated with the recipient user
    var recipientUser = new Parse.User();
    recipientUser.id = recipientUserId
    var pushQuery = new Parse.Query(Parse.Installation)
    pushQuery.equalTo("user", recipientUser)
    
    // Send the push notification to results of the query
    Parse.Push.send({
        where: pushQuery,
        data: {
            alert: message,
            location: location,
            senderId: senderUser.id,
            pushNotificationType: pushNotificationType
        }
    }).then(function() {
        response.success("Push was sent successfully");
    }, function(error) {
        response.error("Push failed to send with error: "+error.message);
    });
});

Parse.Cloud.define("httpRequest", function(request, response){
    var apiKeys = require('cloud/api-keys.js');
    var channel = request.params.recipientId
    var message = request.params.message
    Parse.Cloud.httpRequest({
        url: 'http://pubsub.pubnub.com/publish/' + 
         apiKeys.pubnub('publishKey')   +   '/' + 
         apiKeys.pubnub('subscribeKey') + '/0/' + 
         channel          + '/0/' + 
         encodeURIComponent(JSON.stringify(message)),
    success: function(httpResponse) {
            console.log(httpResponse.text);
            response.success(httpResponse.text);
        },
        error: function(httpResponse) {
            console.error('Request failed with response code ' + httpResponse.status);
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
});
