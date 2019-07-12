//
//  MyCodeTests.swift
//  UnitTestDemoTests
//
//  Created by Jeff Sorrentino on 2/20/19.
//  Copyright © 2019 SeaDogDev. All rights reserved.
//

import XCTest

// import the framework or app as @testable: no need to re-import all of its frameworks
@testable import UnitTestStrategies

// Ensure test coverage is enabled via Edit Scheme, Test, Options
// With coverage enabled, XCode highlights in green the covered code in the right of each tested code file

// General guidance:
// Keep tests small and easy to read, so that they can be maintained
// Add comments re: what you are testing if not obvious

// To disable tests: using the left navigation test section, right click on the test and "Disable..."
//               or: rename the test function so that it does not start with "test" e.g. "disabledTest()"

class MyCodeTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// The simplest test
    func testMySum() {
        XCTAssertEqual(mySum(2, 3), 5)
        
        // 🎉 Unit testing is easy!
    }
    
    // Incorrect: test an asynchronous function
    // This test either "passes" (false positive) or crashes!
    func BADtestMyReverseStringAsyncNoOp() {
        let _ = myReverseStringAsync("string") { completionString in
            XCTAssertEqual(completionString, "gnirt6656s22243444")
        }
    }
    
    // Correct: test an asynchronous function
    func testMyReverseStringAsyncCorrect() {
        // Create an expectation which we "expect" to happen
        // For the description, it's easiest to use #function instead of making up a name
        let expectation = self.expectation(description: #function)
        
        let _ = myReverseStringAsync("string") { completionString in
            // Perform any additional tests before fulfilling the expectation
            XCTAssertEqual(completionString, "gnirts")
            // Now fullfill the expectation
            expectation.fulfill()
        }
        // Only one waitForExpectations can be active at any given time
        waitForExpectations(timeout: 5.0) { error in
            // error rarely contains anything useful
        }
    }
    
    // Alternate strategy: use XCWaiter instead of waitForExpectations
    func testMyReverseStringAsyncWithXCWaiter() {
        let expectation = self.expectation(description: #function)
        
        let _ = myReverseStringAsync("string") { completionString in
            XCTAssertEqual(completionString, "gnirts")
            expectation.fulfill()
        }
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5.0), .completed)
    }
    
    /// This test highlights a problem:
    /// Completion block called multiple times!
    /// This test will normally, but not always, crash.
    func testMyReverseStringAsyncEmpty() {
        let expectation = self.expectation(description: #function)
        
        let _ = myReverseStringAsync("") { completionString in
            XCTAssertEqual(completionString, "")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.1)
        
        //  If we really wanted to,
        //  We could avoid the crash by setting either:
        //    expectation.assertForOverFulfill = false
        //    expectation.expectedFulfillmentCount = 2
    }
    
    // Use an inverted expecation to test for failure
    func testGetResults() {
        let successExpectation = self.expectation(description: #function + "Success")
        
        let failureExpectation = self.expectation(description: #function + "Failure")
        failureExpectation.isInverted = true
        
        getResults("providerName" as AnyObject, success: { results in
            XCTAssertEqual(results?.count, 2)
            successExpectation.fulfill()
        }, failure: { error in
            failureExpectation.fulfill()
        })
        wait(for: [failureExpectation, successExpectation], timeout: 0.1)
    }
    
    // Now test for the real failure
    func testGetResultsFailure() {
        let failureExpectation = self.expectation(description: (#function))
        
        getResults(2222223432 as AnyObject, success: { results in
        }, failure: { error in
            failureExpectation.fulfill()
        })
        wait(for: [failureExpectation], timeout: 0.1)
    }
    
    // Test fulfillment of expectations with an expected order
    func testGetResultsWithStatus() {
        let statusExpectation = self.expectation(description: ("\(#function)status"))
        
        let resultsExpectation = self.expectation(description: ("\(#function)results"))
        
        getResultsWithStatus("providerName" as AnyObject, status: { status in
            statusExpectation.fulfill()
        }) { results in
            resultsExpectation.fulfill()
        }
        
        // This will fail, since the order is incorrect
        // wait(for: [resultsExpectation, statusExpectation], timeout: 0.1, enforceOrder: true)

        // This will pass
        wait(for: [statusExpectation, resultsExpectation], timeout: 0.1, enforceOrder: true)
    }
    
    /// Testing an asynchronous operation without a completion block
    func testPreloadFiles() {
        let loader = FileLoader()
        let backgroundQueue = DispatchQueue(label: "FileLoaderTests")
        
        loader.preloadFiles(["One", "Two", "Three"], on: backgroundQueue)
        
        // Issue an empty closure on backgroundQueue and wait for it to be executed
        backgroundQueue.sync {}
        
        XCTAssertEqual(loader.preloadedFiles, ["One", "Two", "Three"])
    }
    
    /// Testing a notification
    func testNotification() {
        
        let fileLoader = FileLoader()
        
        let _ = expectation(forNotification: .fileLoaded, object: fileLoader
            , handler: { notification -> Bool in
                //test the values of userInfo
                notification.userInfo?["successCode"] as? Int == 1
        })
        fileLoader.loadFile("myFile")
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    /// Testing a delegate
    func testMyClassMessageReceived() {
        let testMessageSender = MessageSender()
        
        //Test that message is received
        let delegateExpectation = expectation(description: #function)
        
        testMessageSender.delegate = MockMessageSenderDelegate(delegateExpectation, expectedMessage: "A testy message was sent!")
        testMessageSender.sendMessage("A testy message")
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
// MARK - test helper functions
    
    class MockMessageSenderDelegate: MessageSenderDelegate {
        
        let expectation: XCTestExpectation
        var expectedMessage: String?
        
        init(_ expectation: XCTestExpectation, expectedMessage: String) {
            self.expectation = expectation
            self.expectedMessage = expectedMessage
        }
        
        func messageReceived(message: String) {
            if message == self.expectedMessage {
                self.expectation.fulfill()
            }
        }
    }
}
