import atexit

from pact import Consumer, Provider

from client import UserClient

pact = Consumer("UserServiceConsumer").has_pact_with(Provider("UserServiceProvider"))
pact.start_service()
atexit.register(pact.stop_service)


def test_get_user():
    expected = {"id": 1, "name": "John Doe"}

    # Define the interaction
    (
        pact.upon_receiving("a request for user with ID 1")
           .given("User with ID 2 exists")
           .with_request("GET", "/users/1")
           .will_respond_with(200, body=expected)
    )

    client = UserClient(pact.uri)

    with pact:
        user = client.get_user(1)
        assert user == expected

    #pact_publisher = PactPublisher(broker_url="http://85.198.80.162:9292", username="admin", password="password")
    #pact_publisher.publish_contract(pact_file_path=".")