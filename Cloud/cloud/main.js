
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
