import ballerinax/github;
import ballerina/http;
import ballerina/test;

@test:Config {}
function foo() returns error? {
    // Create an HTTP client to invoke the service declared in this package
    http:Client ghSvcClient = check new ("http://localhost:9090");
    Repository[] actualRepos = check ghSvcClient->get("/repos/ballerina-platform");

    Repository[] expectedRepos = [
        {name: "openapi", stars: 300},
        {name: "ballerina-spec", stars: 200},
        {name: "ballerina-lang", stars: 100}
    ];
    foreach var index in 0 ... 2 {
        test:assertEquals(actualRepos[index], expectedRepos[index]);
    }
}

// This function mocks the "createGitHubClient" function and returns a mock GitHub client
@test:Mock {functionName: "createGitHubClient"}
function createMockGitHubClient(github:ConnectionConfig config) returns github:Client|error {
    // Create the mock GitHub client
    github:Client ghClient = test:mock(github:Client);
    // Mock the "getRepositories" method and returns test data
    test:prepare(ghClient).when("getRepositories").thenReturn(getMockResponse());
    return ghClient;
}

function getMockResponse() returns stream<github:Repository, github:Error?> {
    GitHubRepoGenerator repGen = new ();
    return new (repGen);
}

// Stream object definition
class GitHubRepoGenerator {
    int index = -1;
    github:Repository[] repos = [
        {createdAt: "", id: "", name: "ballerina-lang", nameWithOwner: "", owner: {id: "", login: ""}, stargazerCount: 100},
        {createdAt: "", id: "", name: "ballerina-spec", nameWithOwner: "", owner: {id: "", login: ""}, stargazerCount: 200},
        {createdAt: "", id: "", name: "openapi", nameWithOwner: "", owner: {id: "", login: ""}, stargazerCount: 300}
    ];

    public isolated function next() returns record {|github:Repository value;|}|github:Error? {
        self.index += 1;
        if self.index < self.repos.length() {
            return {value: self.repos[self.index]};
        } else {
            return ();
        }
    }
}

