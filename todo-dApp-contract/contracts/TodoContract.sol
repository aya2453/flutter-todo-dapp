// TodoContract.sol
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9.0;

contract TodoContract {
  uint256 public totalTasksCount = 0;

  struct Task {
    uint256 id;
    string name;
    bool isComplete;
  }

  mapping(uint256 => Task) public todos;

  event TaskCreated(uint256 id, string name);
  event TaskUpdated(uint256 id, string name);
  event TaskIsCompleteToggled(uint256 id, string name, bool isComplete);
  event TaskDeleted(uint256 id);

  function createTask(string memory _name) public {
    uint256 id = totalTasksCount;
    todos[id] = Task(totalTasksCount, _name, false);
    totalTasksCount++;
    emit TaskCreated(id, _name);
  }

  function updateTask(uint256 _id, string memory _name) public {
    Task memory currentTask = todos[_id];
    todos[_id] = Task(_id, _name, currentTask.isComplete);
    emit TaskUpdated(_id, _name);
  }

  function toggleTaskIsComplete(uint256 _id) public {
    Task memory currentTask = todos[_id];
    todos[_id] = Task(_id, currentTask.name, !currentTask.isComplete);
    emit TaskIsCompleteToggled(
      _id,
      currentTask.name,
      !currentTask.isComplete
    );
  }

  function deleteTask(uint256 _id) public {
    delete todos[_id];
    emit TaskDeleted(_id);
  }
}
