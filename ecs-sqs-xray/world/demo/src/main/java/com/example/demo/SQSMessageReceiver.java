package com.example.demo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.*;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.Message;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageRequest;

import java.util.HashMap;
import java.util.List;
@Component
public class SQSMessageReceiver {

    @Autowired
    SqsClient sqsClient;

    @Autowired
    DynamoDbClient ddbClient;
    public void receiveMessage(){
        String queueUrl = System.getenv("QUEUE_URL");
        ReceiveMessageRequest receiveRequest = ReceiveMessageRequest.builder()
                .queueUrl(queueUrl)
                .build();
        List<Message> messages = sqsClient.receiveMessage(receiveRequest).messages();

        // Process received messages
        for (Message message : messages) {
            System.out.println("Message received: " + message.body());
            System.out.println(message.attributes().toString());
            updateItem(message);
        }
    }

    void updateItem(Message message){
        String tableName = System.getenv("DDB_TABLE_NAME");
        HashMap<String, AttributeValue> itemValues = new HashMap<>();
        itemValues.put("id", AttributeValue.builder().s(System.currentTimeMillis() + "").build());
        itemValues.put("message", AttributeValue.builder().s(message.body()).build());

        PutItemRequest request = PutItemRequest.builder()
                .tableName(tableName)
                .item(itemValues)
                .build();

        try {
            PutItemResponse response = ddbClient.putItem(request);
            System.out.println(tableName + " was successfully updated. The request id is " + response.responseMetadata().requestId());

        } catch (ResourceNotFoundException e) {
            System.err.format("Error: The Amazon DynamoDB table \"%s\" can't be found.\n", tableName);
            System.err.println("Be sure that it exists and that you've typed its name correctly!");
            System.exit(1);
        } catch (DynamoDbException e) {
            System.err.println(e.getMessage());
            System.exit(1);
        }
    }
}
