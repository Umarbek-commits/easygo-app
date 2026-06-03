#!/usr/bin/env python3
"""
Comprehensive Task Management and File Organization System
A feature-rich application for managing tasks, organizing files, and tracking productivity
"""

import os
import json
import sqlite3
import datetime
from pathlib import Path
from typing import List, Dict, Optional, Tuple
from dataclasses import dataclass, asdict
from enum import Enum
import hashlib
import shutil


class TaskPriority(Enum):
    """Task priority levels"""
    LOW = 1
    MEDIUM = 2
    HIGH = 3
    URGENT = 4


class TaskStatus(Enum):
    """Task completion status"""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


@dataclass
class Task:
    """Represents a single task"""
    id: int
    title: str
    description: str
    priority: TaskPriority
    status: TaskStatus
    created_at: datetime.datetime
    due_date: Optional[datetime.datetime]
    completed_at: Optional[datetime.datetime]
    tags: List[str]

    def to_dict(self) -> Dict:
        """Convert task to dictionary"""
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'priority': self.priority.name,
            'status': self.status.value,
            'created_at': self.created_at.isoformat(),
            'due_date': self.due_date.isoformat() if self.due_date else None,
            'completed_at': self.completed_at.isoformat() if self.completed_at else None,
            'tags': self.tags
        }


class DatabaseManager:
    """Manages SQLite database operations"""

    def __init__(self, db_path: str = "tasks.db"):
        self.db_path = db_path
        self.init_database()

    def init_database(self):
        """Initialize database with required tables"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT,
                priority INTEGER NOT NULL,
                status TEXT NOT NULL,
                created_at TEXT NOT NULL,
                due_date TEXT,
                completed_at TEXT,
                tags TEXT
            )
        ''')

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS file_records (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                file_path TEXT NOT NULL UNIQUE,
                file_size INTEGER,
                file_hash TEXT,
                created_at TEXT NOT NULL,
                modified_at TEXT,
                category TEXT
            )
        ''')

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS productivity_log (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date TEXT NOT NULL,
                tasks_completed INTEGER,
                tasks_total INTEGER,
                time_spent INTEGER,
                notes TEXT
            )
        ''')

        conn.commit()
        conn.close()

    def execute_query(self, query: str, params: Tuple = ()):
        """Execute a database query"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute(query, params)
        conn.commit()
        conn.close()

    def fetch_query(self, query: str, params: Tuple = ()):
        """Fetch results from database query"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute(query, params)
        results = cursor.fetchall()
        conn.close()
        return results


class TaskManager:
    """Manages task operations"""

    def __init__(self, db_manager: DatabaseManager):
        self.db = db_manager
        self.tasks: List[Task] = []
        self.load_tasks()

    def create_task(self, title: str, description: str = "", priority: TaskPriority = TaskPriority.MEDIUM,
                    due_date: Optional[datetime.datetime] = None, tags: List[str] = None) -> Task:
        """Create a new task"""
        if tags is None:
            tags = []

        now = datetime.datetime.now()
        query = '''
            INSERT INTO tasks (title, description, priority, status, created_at, due_date, tags)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        '''
        params = (title, description, priority.value, TaskStatus.PENDING.value, now.isoformat(),
                  due_date.isoformat() if due_date else None, json.dumps(tags))

        self.db.execute_query(query, params)

        results = self.db.fetch_query('SELECT last_insert_rowid()')
        task_id = results[0][0]

        task = Task(
            id=task_id,
            title=title,
            description=description,
            priority=priority,
            status=TaskStatus.PENDING,
            created_at=now,
            due_date=due_date,
            completed_at=None,
            tags=tags
        )

        self.tasks.append(task)
        return task

    def update_task_status(self, task_id: int, status: TaskStatus):
        """Update task status"""
        completed_at = datetime.datetime.now().isoformat() if status == TaskStatus.COMPLETED else None

        query = '''
            UPDATE tasks SET status = ?, completed_at = ? WHERE id = ?
        '''
        self.db.execute_query(query, (status.value, completed_at, task_id))

        for task in self.tasks:
            if task.id == task_id:
                task.status = status
                if completed_at:
                    task.completed_at = datetime.datetime.fromisoformat(completed_at)
                break

    def get_tasks_by_priority(self, priority: TaskPriority) -> List[Task]:
        """Get all tasks with specific priority"""
        return [task for task in self.tasks if task.priority == priority]

    def get_overdue_tasks(self) -> List[Task]:
        """Get all overdue tasks"""
        now = datetime.datetime.now()
        return [task for task in self.tasks
                if task.due_date and task.due_date < now and task.status != TaskStatus.COMPLETED]

    def get_tasks_by_status(self, status: TaskStatus) -> List[Task]:
        """Get all tasks with specific status"""
        return [task for task in self.tasks if task.status == status]

    def delete_task(self, task_id: int):
        """Delete a task"""
        query = 'DELETE FROM tasks WHERE id = ?'
        self.db.execute_query(query, (task_id,))
        self.tasks = [task for task in self.tasks if task.id != task_id]

    def load_tasks(self):
        """Load all tasks from database"""
        query = 'SELECT * FROM tasks'
        results = self.db.fetch_query(query)

        self.tasks = []
        for row in results:
            task = Task(
                id=row[0],
                title=row[1],
                description=row[2],
                priority=TaskPriority(row[3]),
                status=TaskStatus(row[4]),
                created_at=datetime.datetime.fromisoformat(row[5]),
                due_date=datetime.datetime.fromisoformat(row[6]) if row[6] else None,
                completed_at=datetime.datetime.fromisoformat(row[7]) if row[7] else None,
                tags=json.loads(row[8]) if row[8] else []
            )
            self.tasks.append(task)

    def search_tasks(self, keyword: str) -> List[Task]:
        """Search tasks by keyword"""
        keyword_lower = keyword.lower()
        return [task for task in self.tasks
                if keyword_lower in task.title.lower() or keyword_lower in task.description.lower()]


class FileOrganizer:
    """Organizes and manages files"""

    def __init__(self, db_manager: DatabaseManager):
        self.db = db_manager

    def calculate_file_hash(self, file_path: str) -> str:
        """Calculate SHA256 hash of a file"""
        sha256_hash = hashlib.sha256()
        with open(file_path, "rb") as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        return sha256_hash.hexdigest()

    def organize_files(self, source_dir: str, target_dir: str):
        """Organize files by category into target directory"""
        source_path = Path(source_dir)
        target_path = Path(target_dir)

        if not source_path.exists():
            raise ValueError(f"Source directory {source_dir} does not exist")

        target_path.mkdir(parents=True, exist_ok=True)

        category_map = {
            '.txt': 'documents',
            '.pdf': 'documents',
            '.doc': 'documents',
            '.docx': 'documents',
            '.jpg': 'images',
            '.jpeg': 'images',
            '.png': 'images',
            '.gif': 'images',
            '.mp3': 'audio',
            '.wav': 'audio',
            '.mp4': 'video',
            '.avi': 'video',
            '.zip': 'archives',
            '.rar': 'archives',
            '.py': 'code',
            '.js': 'code',
            '.java': 'code',
            '.cpp': 'code',
        }

        for file_path in source_path.glob('*'):
            if file_path.is_file():
                file_extension = file_path.suffix.lower()
                category = category_map.get(file_extension, 'other')

                category_dir = target_path / category
                category_dir.mkdir(exist_ok=True)

                destination = category_dir / file_path.name
                shutil.copy2(file_path, destination)

                file_size = file_path.stat().st_size
                file_hash = self.calculate_file_hash(str(file_path))
                now = datetime.datetime.now().isoformat()

                query = '''
                    INSERT OR REPLACE INTO file_records 
                    (file_path, file_size, file_hash, created_at, category)
                    VALUES (?, ?, ?, ?, ?)
                '''
                self.db.execute_query(query, (str(destination), file_size, file_hash, now, category))

    def find_duplicate_files(self) -> List[Tuple[str, str]]:
        """Find duplicate files based on hash"""
        query = 'SELECT file_path, file_hash FROM file_records'
        results = self.db.fetch_query(query)

        hash_map = {}
        duplicates = []

        for file_path, file_hash in results:
            if file_hash in hash_map:
                duplicates.append((hash_map[file_hash], file_path))
            else:
                hash_map[file_hash] = file_path

        return duplicates

    def get_file_statistics(self) -> Dict:
        """Get file statistics"""
        query = 'SELECT category, COUNT(*), SUM(file_size) FROM file_records GROUP BY category'
        results = self.db.fetch_query(query)

        stats = {
            'by_category': {},
            'total_files': 0,
            'total_size': 0
        }

        for category, count, size in results:
            stats['by_category'][category] = {'count': count, 'size': size or 0}
            stats['total_files'] += count
            stats['total_size'] += size or 0

        return stats


class ProductivityTracker:
    """Tracks productivity metrics"""

    def __init__(self, db_manager: DatabaseManager, task_manager: TaskManager):
        self.db = db_manager
        self.task_manager = task_manager

    def log_daily_productivity(self, notes: str = ""):
        """Log daily productivity"""
        today = datetime.date.today().isoformat()
        completed_tasks = self.task_manager.get_tasks_by_status(TaskStatus.COMPLETED)
        total_tasks = len(self.task_manager.tasks)

        query = '''
            INSERT OR REPLACE INTO productivity_log (date, tasks_completed, tasks_total, notes)
            VALUES (?, ?, ?, ?)
        '''
        self.db.execute_query(query, (today, len(completed_tasks), total_tasks, notes))

    def get_productivity_report(self, days: int = 30) -> Dict:
        """Get productivity report for last N days"""
        query = '''
            SELECT date, tasks_completed, tasks_total, notes 
            FROM productivity_log 
            ORDER BY date DESC LIMIT ?
        '''
        results = self.db.fetch_query(query, (days,))

        report = {
            'period_days': days,
            'entries': [],
            'total_completed': 0,
            'average_daily_completion': 0
        }

        for date, completed, total, notes in results:
            report['entries'].append({
                'date': date,
                'completed': completed,
                'total': total,
                'completion_rate': (completed / total * 100) if total > 0 else 0,
                'notes': notes
            })
            report['total_completed'] += completed

        if report['entries']:
            report['average_daily_completion'] = report['total_completed'] / len(report['entries'])

        return report


class ApplicationManager:
    """Main application manager"""

    def __init__(self):
        self.db = DatabaseManager()
        self.task_manager = TaskManager(self.db)
        self.file_organizer = FileOrganizer(self.db)
        self.productivity_tracker = ProductivityTracker(self.db, self.task_manager)

    def display_menu(self):
        """Display main menu"""
        print("\n" + "="*50)
        print("Task Management & File Organization System")
        print("="*50)
        print("1. Create Task")
        print("2. View Tasks by Status")
        print("3. View Overdue Tasks")
        print("4. Update Task Status")
        print("5. Search Tasks")
        print("6. Organize Files")
        print("7. Find Duplicate Files")
        print("8. View File Statistics")
        print("9. View Productivity Report")
        print("10. Exit")
        print("="*50)

    def run(self):
        """Run the application"""
        while True:
            self.display_menu()
            choice = input("Enter your choice (1-10): ").strip()

            if choice == '1':
                self.create_task_interactive()
            elif choice == '2':
                self.view_tasks_interactive()
            elif choice == '3':
                self.view_overdue_tasks()
            elif choice == '4':
                self.update_task_interactive()
            elif choice == '5':
                self.search_tasks_interactive()
            elif choice == '6':
                self.organize_files_interactive()
            elif choice == '7':
                self.find_duplicates()
            elif choice == '8':
                self.view_file_stats()
            elif choice == '9':
                self.view_productivity()
            elif choice == '10':
                print("Thank you for using the application!")
                break
            else:
                print("Invalid choice. Please try again.")

    def create_task_interactive(self):
        """Interactive task creation"""
        title = input("Enter task title: ").strip()
        description = input("Enter task description (optional): ").strip()
        priority = int(input("Priority (1=Low, 2=Medium, 3=High, 4=Urgent): "))

        task = self.task_manager.create_task(
            title=title,
            description=description,
            priority=TaskPriority(priority)
        )
        print(f"Task created with ID: {task.id}")

    def view_tasks_interactive(self):
        """Interactive task viewing"""
        status = input("Enter status (pending/in_progress/completed): ").strip()
        tasks = self.task_manager.get_tasks_by_status(TaskStatus(status))

        for task in tasks:
            print(f"ID: {task.id}, Title: {task.title}, Priority: {task.priority.name}")

    def view_overdue_tasks(self):
        """View overdue tasks"""
        overdue = self.task_manager.get_overdue_tasks()
        for task in overdue:
            print(f"ID: {task.id}, Title: {task.title}, Due: {task.due_date}")

    def update_task_interactive(self):
        """Interactive task update"""
        task_id = int(input("Enter task ID: "))
        status = input("Enter new status (pending/in_progress/completed): ").strip()
        self.task_manager.update_task_status(task_id, TaskStatus(status))
        print("Task updated successfully!")

    def search_tasks_interactive(self):
        """Interactive task search"""
        keyword = input("Enter search keyword: ").strip()
        results = self.task_manager.search_tasks(keyword)

        for task in results:
            print(f"ID: {task.id}, Title: {task.title}")

    def organize_files_interactive(self):
        """Interactive file organization"""
        source = input("Enter source directory: ").strip()
        target = input("Enter target directory: ").strip()

        try:
            self.file_organizer.organize_files(source, target)
            print("Files organized successfully!")
        except ValueError as e:
            print(f"Error: {e}")

    def find_duplicates(self):
        """Find and display duplicate files"""
        duplicates = self.file_organizer.find_duplicate_files()

        if duplicates:
            print("\nDuplicate files found:")
            for original, duplicate in duplicates:
                print(f"  Original: {original}")
                print(f"  Duplicate: {duplicate}\n")
        else:
            print("No duplicate files found.")

    def view_file_stats(self):
        """View file statistics"""
        stats = self.file_organizer.get_file_statistics()

        print("\nFile Statistics:")
        print(f"Total Files: {stats['total_files']}")
        print(f"Total Size: {stats['total_size'] / (1024*1024):.2f} MB")
        print("\nBy Category:")

        for category, data in stats['by_category'].items():
            print(f"  {category}: {data['count']} files, {data['size'] / 1024:.2f} KB")

    def view_productivity(self):
        """View productivity report"""
        report = self.productivity_tracker.get_productivity_report()

        print("\nProductivity Report:")
        print(f"Total Completed: {report['total_completed']}")
        print(f"Average Daily: {report['average_daily_completion']:.2f}")
        print("\nDetailed entries:")

        for entry in report['entries']:
            print(f"  {entry['date']}: {entry['completed']}/{entry['total']} ({entry['completion_rate']:.1f}%)")


def main():
    """Main entry point"""
    app = ApplicationManager()
    app.run()


if __name__ == "__main__":
    main()
